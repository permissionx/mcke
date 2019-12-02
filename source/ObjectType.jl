abstract type Obj end
abstract type DefectObj <: Obj end
# Defect types
mutable struct Vacancy <: DefectObj
    id::Int64
    typeNum::Int64
    position::Vector{Int64}
    size::Int64
    eventContainer::EventContainer{ObjEvent}
    cellIndex::Vector{Int64}
    dismissed::Bool
end
function Vacancy(position::Vector{Int64}, size::Int64)
    events = Vector{ObjEvent}(undef, 8)
    events[1] = Move([1,1,1])
    events[2] = Move([1,-1,1])
    events[3] = Move([1,1,-1])
    events[4] = Move([1,-1,-1])
    events[5] = Move([-1,1,1])
    events[6] = Move([-1,-1,1])
    events[7] = Move([-1,1,-1])
    events[8] = Move([-1,-1,-1])
    fres = [0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1]/size^3
    fre = sum(fres)
    eventContainer = EventContainer(fre, fres, events)
    Vacancy(0, 1, position, size, eventContainer, Vector{Int64}(), false)
end

mutable struct Interstitial <: DefectObj
    id::Int64
    typeNum::Int64
    position::Vector{Int64}
    size::Int64
    direction::Vector{Int64}
    eventContainer::EventContainer{ObjEvent}
    cellIndex::Vector{Int64}
    dismissed::Bool
end
function Interstitial(position::Vector{Int64}, size::Int64, direction::Vector{Int64})
    events = Vector{ObjEvent}(undef, 2)
    events[1] = Slip(1)
    events[2] = Slip(-1)
    fres = [100,100]/(size^0.5)
    fre = sum(fres)
    eventContainer = EventContainer(fre, fres, events)
    Interstitial(0, 2, position, size, direction, eventContainer, Vector{Int64}(), false)
end

#-
abstract type UniverseObj <: Obj end
struct UniverseEventHolder <: UniverseObj
    eventContainer::EventContainer{UniverseEvent}
end
