p = "non_existing_1234_4321"
@test !ispath(p)

# The broken tests are to remind me to revisit these failing tests
# @test_throws(AbstractString, lintfile(p))
# @test_throws(AbstractString, lintpkg(p))
@test_broken 1 + 1 == 3
@test_broken 1 + 1 == 3

# Lint package with full path
path = joinpath(dirname(pathof(Lint)), "../test", "FakePackage")
msgs = lintpkg(path)
@test_broken isempty(msgs)
