s = """
r = 5:1
"""
msgs = lintstr(s)
@test_broken msgs[1].code == :E433
@test_broken occursin("for a decreasing range, use a negative step e.g. 10:-1:1", msgs[1].message)

s = """
x = [1,2,7,8]
y = [3,4,5,6]
splice!(x, 3:2, y)
"""
msgs = lintstr(s)
@test isempty(msgs)

s = """
function f(r::UnitRange)
    return r == 0:-1
end
"""
msgs = lintstr(s)
@test isempty(msgs)

s = """
function f(r::UnitRange)
    a = r[2]
    b = r[3:4]
    @lintpragma("Info type r")
    @lintpragma("Info type a")
    @lintpragma("Info type b")
    (a,b)
end
"""
msgs = lintstr(s)
@test_broken msgs[1].code == :I271
@test_broken occursin("typeof(r) == UnitRange", msgs[1].message)
@test_broken msgs[2].code == :I271
@test_broken occursin("typeof(a) == Any", msgs[2].message)
@test_broken msgs[3].code == :I271
@test_broken occursin("typeof(b) == UnitRange", msgs[3].message)
