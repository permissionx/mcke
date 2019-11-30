# Obj Events
abstract type Event end
abstract type BaseEvent <: Event end # Basic || influencial
abstract type HighLvlEvent <: Event end #

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

#-- ReSize
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

