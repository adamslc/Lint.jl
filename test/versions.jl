s = """
if VERSION < v"0.4-" && VERSION > v"0.1"
    @lintpragma("Info version 0.3")
    @lintpragma("Info version 0.4")
else
    @lintpragma("Info version 0.3")
    @lintpragma("Info version 0.4")
end
"""
msgs = lintstr(s)
@test_broken msgs[1].code == :I271
@test_broken occursin("Reachable by 0.3", msgs[1].message)
@test_broken occursin("Unreachable by 0.4", msgs[2].message)
@test_broken occursin("Unreachable by 0.3", msgs[3].message)
@test_broken occursin("Reachable by 0.4", msgs[4].message)

s = """
test() = true
if VERSION < v"0.4-" && test()
    @lintpragma("Info version 0.3")
    @lintpragma("Info version 0.4.0-dev+1833")
else
    @lintpragma("Info version 0.3")
    @lintpragma("Info version 0.4.0-dev+1833")
end
"""
msgs = lintstr(s)
@test length(msgs) == 4
@test_broken msgs[1].code == :I271
@test_broken occursin("Reachable by 0.3", msgs[1].message)
@test_broken occursin("Unreachable by 0.4", msgs[2].message)
@test_broken occursin("Reachable by 0.3", msgs[3].message)
@test_broken occursin("Reachable by 0.4", msgs[4].message) # we cannot prove unreachable

s = """
test() = true
if VERSION < v"0.4-" || test()
    @lintpragma("Info version 0.3")
    @lintpragma("Info version 0.4.0-dev+1833")
else
    @lintpragma("Info version 0.3")
    @lintpragma("Info version 0.4.0-dev+1833")
end
"""
msgs = lintstr(s)
@test length(msgs) == 4
@test_broken msgs[1].code == :I271
@test_broken occursin("Reachable by 0.3", msgs[1].message)
@test_broken occursin("Reachable by 0.4", msgs[2].message)
@test_broken occursin("Unreachable by 0.3", msgs[3].message)
@test_broken occursin("Reachable by 0.4", msgs[4].message)

# testing `||`, should be rare
s = """
if VERSION >= v"0.4-" || VERSION < v"0.3"
    @lintpragma("Info version 0.3")
    @lintpragma("Info version 0.4.0-dev+1833")
else
    @lintpragma("Info version 0.3")
    @lintpragma("Info version 0.4.0-dev+1833")
end
"""
msgs = lintstr(s)
@test length(msgs) == 4
@test_broken msgs[1].code == :I271
@test_broken occursin("Unreachable by 0.3", msgs[1].message)
@test_broken occursin("Reachable by 0.4", msgs[2].message)
@test_broken occursin("Reachable by 0.3", msgs[3].message)
@test_broken occursin("Unreachable by 0.4", msgs[4].message)

s = """
if !(VERSION >= v"0.4-")
    @lintpragma("Info version 0.3")
    @lintpragma("Info version 0.4.0-dev+1833")
else
    @lintpragma("Info version 0.3")
    @lintpragma("Info version 0.4.0-dev+1833")
end
"""
msgs = lintstr(s)
@test_broken msgs[1].code == :I271
@test_broken occursin("Reachable by 0.3", msgs[1].message)
@test_broken occursin("Unreachable by 0.4", msgs[2].message)
@test_broken occursin("Unreachable by 0.3", msgs[3].message)
@test_broken occursin("Reachable by 0.4", msgs[4].message)
