@testset "E332" begin
    s = """
    function f()
        call = "hi" # this is just asking for trouble
        call
    end
    """
    msgs = lintstr(s)
    @test msgs[1].code == :E332
    @test msgs[1].variable == "call"
    @test occursin("should not be used as a variable name", msgs[1].message)
end

@testset "I342" begin
    s = """
    function f()
        var = "hi" # this is just asking for trouble
        var
    end
    """
    msgs = lintstr(s)
    @test_broken msgs[1].code == :I342
    @test_broken msgs[1].variable == "var"
    @test_broken occursin("local variable", msgs[1].message)
    @test_broken occursin("shadows export from Base", msgs[1].message)
end
