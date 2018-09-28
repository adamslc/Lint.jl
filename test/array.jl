@assert [[1;2];[3;4]] == [1;2;3;4]
s = """
r = [[1;2];[3;4]]
"""
msgs = lintstr(s)
@test msgs[1].code == :W444
@test occursin("nested vcat is treated as a 1-dimensional array", msgs[1].message)

s = """
r = [[1,2],[3,4]]
"""
msgs = lintstr(s)
@test isempty(msgs)

@assert [[1 2] [3 4]] == [1 2 3 4]
s = """
r = [[1 2]  [3 4]]
"""
msgs = lintstr(s)
@test msgs[1].code == :W445
@test occursin("nested hcat is treated as a 1-row horizontal array of " *
    "dim=2", msgs[1].message)

s = """
x = Any[[1,2],[7,8]]
y = Array[[1,2],[3,4]]
"""
msgs = lintstr(s)
@test isempty(msgs)

s = """
function f(x::Array{Float64,2})
    y = x[1, 2, 3]
    y
end
"""
msgs = lintstr(s)
@test_broken msgs[1].code == :E436
@test_broken occursin("more indices than dimensions", msgs[1].message)

s = """
function f(x::Array{Float64,2})
    x[1, 2, 3]
end
"""
msgs = lintstr(s)
@test_broken msgs[1].code == :E436
@test_broken occursin("more indices than dimensions", msgs[1].message)

s = """
function f(x::Array{Float64,2})
    y = x[Colon(), 1]
    for i in y
        println(i)
    end
end
"""
msgs = lintstr(s)
@test_broken isempty(msgs)

s = """
function f(x::Array{Float64,2})
    y = x[1,1]
    @lintpragma("Info type y")
end
"""
msgs = lintstr(s)
@test_broken msgs[1].code == :I271
@test_broken occursin("typeof(y) == Float64", msgs[1].message)

s = """
function f(t)
    x1 = zeros(1, 2)
    x2 = zeros(Int64, 2, 2)
    x3 = zeros(t, 2, 2)
    x4 = zeros(x1)
    @lintpragma("Info type x1")
    @lintpragma("Info type x2")
    @lintpragma("Info type x3")
    @lintpragma("Info type x4")
end
"""
msgs = lintstr(s)
@test_broken msgs[1].code == :I271
@test_broken occursin("typeof(x1) == Array{Float64,2}", msgs[1].message)
@test_broken msgs[2].code == :I271
@test_broken occursin("typeof(x2) == Array{Int64,2}", msgs[2].message)
@test_broken msgs[3].code == :I271
@test_broken occursin("typeof(x3) == $Array", msgs[3].message)
@test_broken msgs[4].code == :I271
@test_broken occursin("typeof(x4) == Array{Float64,2}", msgs[4].message)

# more array function
s = """
function f(t::Array{Int64,2}, m, n)
    x2 = reshape(t, 1)
    x3 = reshape(t, (1,2))
    x4 = reshape(m, (1,2))
    x6 = reshape(t, 1, 2)
    x7 = t'
    x8 = (1, 2)
    @lintpragma("Info type x2")
    @lintpragma("Info type x3")
    @lintpragma("Info type x4")
    @lintpragma("Info type x6")
    @lintpragma("Info type x7")
    @lintpragma("Info type x8")
end
"""
msgs = lintstr(s)
@test_broken msgs[1].code == :I271
@test_broken occursin("typeof(x2) == Array{Int64,1}", msgs[1].message)
@test_broken msgs[2].code == :I271
@test_broken occursin("typeof(x3) == Array{Int64,2}", msgs[2].message)
@test_broken msgs[3].code == :I271
@test_broken occursin("typeof(x4) == Any", msgs[3].message)
@test_broken msgs[4].code == :I271
@test_broken occursin("typeof(x6) == Array{Int64,2}", msgs[4].message)
@test_broken msgs[5].code == :I271
@test_broken occursin("typeof(x7) == Array{Int64,2}", msgs[5].message)

s = """
function f(a::Array{Float64})
    x = a[1,2]
    @lintpragma("Info type x")
    return x
end
"""
msgs = lintstr(s)
# it could be Float64, or it could be an array still!
@test_broken msgs[1].code == :I271
@test_broken occursin("typeof(x) == Any", msgs[1].message)

s = """
s = "abcdef"
s = s[chr2ind(s,2) :end]
"""
msgs = lintstr(s)
@test msgs[1].code == :I681
@test occursin("ambiguity of :end as a symbol vs as part of a range", msgs[1].message)

s = """
s = "abcdef"
sndlast = s[end -1]
"""
msgs = lintstr(s)
@test msgs[1].code == :I682
@test occursin("ambiguity of `[end -n]` as a matrix row vs index [end-n]", msgs[1].message)

s = """
function f()
    x1 = zeros(100, 100)
    x2 = Array(Float64, (100, 100))
    x1[1, 1]
    x2[1, 1]
end
"""
msgs = lintstr(s)
@test isempty(msgs)

s = """
function f(y::Array{Float64, 3}, x1::Int64)
    reshape(y[Colon(), x1, Colon()]', size(y, 1), size(y, 3)')
end
"""
msgs = lintstr(s)
@test_broken isempty(msgs)
