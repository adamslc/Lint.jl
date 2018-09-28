@testset "E522" begin
    msgs = lintstr("""
    s = I
    println(s[1])
    """)
    
    @test_broken messageset(msgs) == Set([:E522])
    @test_broken msgs[1].variable == "s[1]"
    @test_broken occursin("indexing UniformScaling", msgs[1].message)
    @test_broken occursin("with index types $Int is not supported", msgs[1].message)

    # dicts
    @test messageset(lintstr("""
    s = keys(Dict(1 => 2))
    println(s["foo"])
    """)) == Set([:E522])
    @test messageset(lintstr("""
    s = Dict(1 => 2)
    println(s["foo"])
    """)) == Set([:E522])
    @test isempty(messageset(lintstr("""
    s = Dict(1 => 2)
    println(s[1])
    """)))

    msgs = lintstr("""
    function f()
        a = 1
        d = Dict{Symbol,Int}(:a=>1, :b=>2)
        x = d[a]
        return x
    end
    """)
    @test_broken messageset(msgs) == Set([:E522, :E539])
    @test_broken msgs[1].variable == "d[a]"
    @test_broken occursin("indexing Dict", msgs[1].message)
    @test_broken occursin("Int", msgs[1].message)

    # strings
    msgs = lintstr("""
    function f()
        b = repeat(" ", 10)
        b[:start]
    end
    """)
    @test messageset(msgs) == Set([:E522])
    @test msgs[1].variable == "b[:start]"
    @test occursin("indexing String", msgs[1].message)
    @test occursin("with index types Symbol is not supported", msgs[1].message)

    # zero-dimensional indexing
    msgs = lintstr("""
    d = Dict()
    x = d[]
    """)
    @test messageset(msgs) == Set([:E522, :E539])
    @test occursin("indexing Dict", msgs[1].message)
    @test occursin("with no indices is not supported", msgs[1].message)

    msgs = lintstr("""
    a = ""
    a[]
    """)
    @test messageset(msgs) == Set([:E522])
    @test occursin("indexing String with no indices", msgs[1].message)

    # issue 196
    @test messageset(lintstr("""
    s = Dict(:b => 2)
    println(keys(s)[1])
    """)) == Set([:E522])
end
