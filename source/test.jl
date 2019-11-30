using PProf 
function test()
    for _ in 1:10
        println("Hello World")
    end
end

@pprof test()