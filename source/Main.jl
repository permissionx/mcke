using StatsBase
using BenchmarkTools

# Types and basic methods
include("EventType.jl")
include("ObjectType.jl")
include("UniverseType.jl")

# Functions 
include("Event.jl")
include("Universe.jl")
include("NeighbourObj.jl")
include("BoundaryCondition.jl")  
include("Object.jl")



###
######################################################
const boundary = [0 1000; 0 1000; 0 1000]
const initTemp = 300.0

function CustomEvents(universe)
    if universe.thermo.iterTime == 0
        println("Start")
    end
    if universe.thermo.iterTime % 100 == 0
        IntroduceRandomDefects(universe, 10, 100)
        println(universe.thermo.time)
    end
end

function StopEvents(universe)
    if universe.thermo.iterTime  >=  10000
        universe.stop = true
    end
end


function Evolve()
    universe = InitlUniverse()
    while true
        EssentialEvents(universe)
        CustomEvents(universe)
        if universe.stop == true
            break
        end
    end
end

using PProf
@time Evolve()
#pprof(;webhost="115.25.142.8")


