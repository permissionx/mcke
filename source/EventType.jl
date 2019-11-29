# Events
abstract type Event end

#- Disappear
struct Disappear <: Event
end

#- Appear
struct Appear <: Event
end
#- Move
struct Move <: Event
    dr::Vector{Int64}
end

#- Swallow
struct Swallow <: Event
end

#- Resize
struct Resize <: Event
    newSize::Int64
end

struct UniverseEvent
    should
    introduce!
end
