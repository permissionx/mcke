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


# Process Control
#1

function ShouldStop(universe::Universe)
    local should::Bool
    if universe.thermo.iterTime == 100000000
        should = true
    else
        should = false
    end
    should
end
function UniverseStop(universe::Universe)
    universe.stop = true
    println("STOP")
end
event2 = UniverseEvent(ShouldStop, UniverseStop)


#2
function Should(universe::Universe)
    local should::Bool
    if universe.thermo.iterTime % 1000000 == 0
        should = true
    else
        should = false
    end
    should
end
function Intro(univser::Universe)
    IntroduceRandomDefects(universe, 10, 50)
    println(universe.thermo.iterTime)
    println(length(universe))
    println()
end

event1 = UniverseEvent(Should, Intro)


###
######################################################
universeEvents = addUniverseEvents([event1,event2])
boundary = [0 1000; 0 1000; 0 1000]
initTemp = 300.0
universe = Universe(boundary, initTemp)
IntroduceRandomDefects(universe, 10, 50)
@code_warntype Evolve(universe, universeEvents)


