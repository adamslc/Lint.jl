function lintpkg(pkg::AbstractString)
    p = pkg
    if !ispath(p)
        throw("cannot find path: " * p)
    end
    LintResult(lintpkgforfile(p))
end

"""
Lint the package for a file.
If file is in src, lint Package.jl and its includes.
If file is in test, lint runtests.jl and its includes.
If file is in base lint all files in base dir.
"""
function lintpkgforfile(path::AbstractString, ctx::LintContext=LintContext())
    path = abspath(path)
    if ispath(ctx.path)
        if Sys.iswindows()
            len = count(x -> x == '\\', path)
        else
            len = count(x -> x == '/', path) - 1
        end
        for _ = 1:len
            path, folder = splitdir(path)
            if folder == "src"
                file = joinpath(path, folder, basename(path) * ".jl")
                if ispath(file)
                    lintinclude(ctx, file)
                end
                break
            elseif folder == "test"
                file = joinpath(path, folder, "runtests.jl")
                if ispath(file)
                    lintinclude(ctx, file)
                end
                break
            elseif folder == "base"
                lintdir(joinpath(path, folder), ctx)
                break
            end
        end
    end
    finish(ctx)
    ctx.messages
end

function lintfile(f::AbstractString)
    if !ispath(f)
        throw("no such file exists")
    end
    str = open(io -> read(io, String), f)
    lintfile(f, str)
end

function lintfile(f::AbstractString, code::AbstractString)
    ctx = LintContext(f)

    _lintstr(code, ctx)
    finish(ctx)
    msgs = ctx.messages

    # If we have an undeclared symbol, lint the package to try and resolve
    for message in msgs
        if message.code == :E321 # undeclared symbol
            ctx = LintContext(f)
            message = lintpkgforfile(file(ctx), ctx)
            break
        end
    end

    filter!(msg -> file(msg) == f, msgs)
    sort!(msgs)

    LintResult(msgs)
end

function _lintstr(str::AbstractString, ctx::LintContext, lineoffset = 0)
    linecharc = [0; cumsum(map(x->length(x)+1, split(str, "\n", keepempty=true)))]
    numlines = length(linecharc)

    i = 1
    while i <= length(str)
        problem = false
        ex = nothing
        linerange = searchsorted(linecharc, i)

        # Check for end of file
        if first(linerange) > numlines
            break
        end

        linebreakloc = linecharc[first(linerange)]

        if linebreakloc == i || isempty(strip(str[i:(linebreakloc-1)]))# empty line
            i = linebreakloc + 1
            continue
        end
        ctx.line = ctx.lineabs = first(linerange) + lineoffset
        try
            (ex, i) = Meta.parse(str,i)
        catch y
            if typeof(y) != Meta.ParseError || y.msg != "end of input"
                msg(ctx, :E111, string(y))
            end
            break
        end
        lintexpr(ex, ctx)
    end
end

"""
    lintstr(s::AbstractString)

Unlike other lint functions, like `lintpkg` and `lintfile`, `lintstr` does not
ignore any messages by default.
"""
function lintstr(str::AbstractString,
                 ctx::LintContext = (c = LintContext(); c.ignore = []; c))
    _lintstr(str, ctx)
    finish(ctx)
    ctx.messages
end

"""
Lint all .jl ending files at a given directory.
Will ignore LintContext file and already included files.
"""
function lintdir(dir::AbstractString, ctx::LintContext=LintContext())
    for file in readdir(dir)
        if endswith(file, ".jl")
            file = joinpath(dir, file)
            if !isdir(file)
                lintinclude(ctx, file)
            end
        end
    end
    finish(ctx)
    ctx.messages
end
