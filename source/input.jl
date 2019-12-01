const boundary = [0 70; 0 70; 0 70]
const initTemp = 300.0
const totalTime = 10
const outputInterval = 0.1
const boundaryCondition = "open"

include("../Main.jl")

function CustomEvents(universe::Universe)
    if universe.thermo.iterTime == 0
        universe.cache["outputTime"] = 0
        println("Start")
        event = IntroduceRandomDefects(100,1)
        DefineUniverseEvent(universe, event, 1.0)
    end

    if universe.thermo.time > universe.cache["outputTime"]
        println(universe.thermo.iterTime, " ",
                universe.thermo.time, " ",
                length(universe)," ",
                universe.fre, " ")
        Dump(universe, "run.dump")
        universe.cache["outputTime"] += outputInterval
    end

end

function StopEvents(universe::Universe)
    if universe.thermo.time  >=  totalTime
        Dump(universe, "run.dump")
        universe.stop = true
    end
end



using PProf
Random.seed!(20191201)
@time Evolve()
#pprof(;webhost="115.25.142.8")
