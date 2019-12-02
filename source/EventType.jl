abstract type Event end
abstract type ObjEvent <: Event end
abstract type BaseEvent <: ObjEvent end # Basic || influencial
abstract type HighLvlEvent <: ObjEvent end #
abstract type UniverseEvent <: Event end

# Obj Events


#- Base
#-- Disappear
struct Disappear <: BaseEvent
end

#-- Appear
struct Appear <: BaseEvent
end
#-- Move
struct Move <: BaseEvent
    dr::Vector{Int64}
end

#-- ReSize
struct ReSize <: BaseEvent
    newSize::Int64
end


#- High level 
struct ReDirection <: HighLvlEvent
    newDirection::Vector{Int64}
end

#-- Swallow
struct Swallow <: HighLvlEvent
end

#-- Slip
struct Slip <: HighLvlEvent
    upAndDown::Int64
end

#-- ReFre
struct ReFres <: HighLvlEvent
    newFres::Vector{Float64}
end


# Universe Event
struct IntroduceRandomDefects <: UniverseEvent
    numDefects::Int64
    maxSize::Int64
end



# Event Container
mutable struct EventContainer{T<:Event}
    fre::Float64
    fres::Vector{Float64}
    events::Vector{T}
end