#!/usr/bin/env lua
-- userdparser2.lua
-- Glenn G. Chappell
-- 2020-02-12
--
-- For CS F331 / CSCE A331 Spring 2020
-- Simple Main Program for rdparser2 Module
-- Requires rdparser2.lua

rdparser2 = require "rdparser2"


-- check
-- Given a "program", check its syntactic correctness using rdparser2.
-- Print results.
function check(program)
    dashstr = "-"
    io.write(dashstr:rep(72).."\n")
    io.write("Program: "..program.."\n")

    local good, done = rdparser2.parse(program)
    assert(type(good) == "boolean")
    assert(type(done) == "boolean")

    if good then
        io.write("Syntactically correct; ")
    else
        io.write("NOT SYNTACTICALLY CORRECT; ")
    end

    if done then
        io.write("all input parsed\n")
    else
        io.write("NOT ALL INPUT PARSED\n")
    end

    io.write("Conclusion: ")
    if good and done then
        io.write("Good!\n")
    elseif good and not done then
        io.write("Bad - extra characters at end\n")
    elseif not good and done then
        io.write("Unfinished - please add more\n")
    else  -- not good and not done
        io.write("Bad - syntax error\n")
    end
end


-- Main program
-- Check several "programs".
io.write("Recursive-Descent Parser: More Complex\n")
check("")
check("xyz")
check("123")
check("%")
check("((abc_39))")
check("(((((%)))))")
check("(a,b,c)")
check("(((x))")
check("((x)))")
check("a,b,c")
check("a:b,c:d:e")
check("*-[%]")
check("*[x]")
check("((*-[(((a,b:c:d)))]))")
check("((*-[(((a,b:c:d)))]))&")
check("(*-[((b:c,d))")

