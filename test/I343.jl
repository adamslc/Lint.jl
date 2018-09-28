@testset "I343" begin
    @testset "Type Alias Shadowing" begin
        s = """
        const TT = Int64
        @compat SharedVector{X} = SharedArray{X,1}

        type MyType{X}
            t::X
            MyType{X}(x) where X = new(convert(X, x))
        end
        """
        msgs = lintstr(s)
        @test_broken messageset(msgs) == Set([:I343])
        @test_broken msgs[1].variable == "SharedVector"
    end

    msgs = lintstr("""
    e = 1
    """)
    @test_broken messageset(msgs) == Set([:I343])
    @test_broken occursin("with same name as export from Base", msgs[1].message)

    @test_broken isempty(lintstr("""
    import Base: parent
    immutable MyType end
    parent(_::MyType) = MyType()
    """))
end
