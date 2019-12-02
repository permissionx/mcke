using StatsBase
using BenchmarkTools
using Random

# Types and basic methods
include("EventType.jl")
include("ObjectType.jl")
include("NeighbourObjType.jl")
include("UniverseType.jl")

# Functions 
include("Event.jl")
include("Universe.jl")
include("NeighbourObj.jl")
include("BoundaryCondition.jl") 
if boundaryCondition == "open"
    using .OpenBoundaryCondition
elseif boundaryCondition == "PPP"
    using .PPPBoundaryCondition
end 
include("Object.jl")



function Evolve()
    universe = InitlUniverse()
    while true
        CustomEvents(universe)
        EssentialEvents(universe)
        StopEvents(universe)
        if universe.stop == true
            break
        end
    end
    universe
end


