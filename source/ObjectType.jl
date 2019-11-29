# Event Container
mutable struct EventsContainer
    fre::Float64
    fres::Vector{Float64}
    events::Vector{Event}
end

abstract type Obj end
# Defect types
mutable struct Vacancy <: Obj
    position::Vector{Int64}
    size::Int64
    eventsContainer::EventsContainer
    dismissed::Bool
end
function Vacancy(position::Vector{Int64}, size::Int64)
    events = Vector{Event}(undef, 4)
    events[1] = Move([1,1,1])
    events[2] = Move([1,-1,1])
    events[3] = Move([1,1,-1])
    events[4] = Move([1,-1,-1])
    fres = [1,1,1,1]/size
    fre = sum(fres)
    eventsContainer = EventsContainer(fre, fres, events)
    Vacancy(position, size, eventsContainer, false)
end

mutable struct Interstitial <: Obj
    position::Vector{Int64}
    size::Int64
    direction::Vector{Int64}
    eventsContainer::EventsContainer
    dismissed::Bool
end
function Interstitial(position::Vector{Int64}, size::Int64, direction::Vector{Int64})
    events = Vector{Event}(undef, 2)
    events[1] = Move(direction)
    events[2] = Move(-direction)
    fres = [1,1]/size
    fre = sum(fres)
    eventsContainer = EventsContainer(fre, fres, events)
    Interstitial(position, size, direction, eventsContainer, false)
end


