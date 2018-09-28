@testset "using" begin
    @test isempty(lintstr("""
    module TmpTestBase
        export foobar
        foobar(x) = x
    end

    module Test
        using ..TmpTestBase
        g(x) = foobar(x)
    end
    """))
end
