using Debugger

const boundary = [0 100; 0 100; 0 100]
const initTemp = 300.0
const totalTime = 10
const outputInterval = 0.1
const cellCutoff = 10.0
const boundaryCondition = "PPP"

include("Main.jl")

function CustomEvents(universe::Universe)
    if universe.thermo.iterTime == 0
        universe.cache["outputTime"] = 0
        println("Start")
        #event = IntroduceRandomDefects(100,1)
        #DefineUniverseEvent(universe, event, 1.0)
        Introduce!(universe, [IntroduceRandomDefects(1000,1)])
    end

    #if universe.thermo.time > universe.cache["outputTime"]
    if universe.thermo.iterTime % 1000 == 0 
        println(universe.thermo.iterTime, " ",
                universe.thermo.time, " ",
                length(universe)," ",
                universe.fre, " ",
                universe.objs[1].position[1])
        Dump(universe, "run.dump") 
        universe.cache["outputTime"] += outputInterval
    end
end

function StopEvents(universe::Universe)
    #if universe.thermo.time  >=  totalTime
    if universe.thermo.iterTime > 100000
        println(universe.thermo.iterTime)
        #Dump(universe, "run.dump")
        universe.stop = true
    end
end

global debug= Vector()
Random.seed!(20191201)
using BenchmarkTools
Evolve()
#pprof(;webhost="115.25.142.8")

