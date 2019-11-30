# Event Container
mutable struct EventsContainer
    fre::Float64
    fres::Vector{Float64}
    events::Vector{Event}
end

abstract type Obj end
# Defect types
mutable struct Vacancy <: Obj
    id::Int64
    typeNum::Int64
    position::Vector{Int64}
    size::Int64
    eventsContainer::EventsContainer
    dismissed::Bool
end
function Vacancy(position::Vector{Int64}, size::Int64)
    events = Vector{Event}(undef, 8)
    events[1] = Move([1,1,1])
    events[2] = Move([1,-1,1])
    events[3] = Move([1,1,-1])
    events[4] = Move([1,-1,-1])
    events[5] = Move([-1,1,1])
    events[6] = Move([-1,-1,1])
    events[7] = Move([-1,1,-1])
    events[8] = Move([-1,-1,-1])
    fres = [0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1]/size
    fre = sum(fres)
    eventsContainer = EventsContainer(fre, fres, events)
    Vacancy(0, 1, position, size, eventsContainer, false)
end

mutable struct Interstitial <: Obj
    id::Int64
    typeNum::Int64
    position::Vector{Int64}
    size::Int64
    direction::Vector{Int64}
    eventsContainer::EventsContainer
    dismissed::Bool
end
function Interstitial(position::Vector{Int64}, size::Int64, direction::Vector{Int64})
    events = Vector{Event}(undef, 2)
    events[1] = Slip(1)
    events[2] = Slip(-1)
    fres = [100,100]/size
    fre = sum(fres)
    eventsContainer = EventsContainer(fre, fres, events)
    Interstitial(0, 2, position, size, direction, eventsContainer, false)
end


