# Universal properties
struct Map
    interstitialDirections::Vector{Vector{Int64}}
end
function Map(nDimension::Int64)
    Map(generateIntersitialDirections(nDimension))
end

mutable struct Box 
    map::Map
    nDimension::Int64
    halfLength::Vector{Float64}
    length::Vector{Int64}
    boundary::Matrix{Int64}
end
function Box(boundary::Matrix{Int64})
    nDimension = size(boundary)[1]
    length = boundary[:,2] - boundary[:,1]
    halfLength = length/2.0
    map = Map(nDimension)
    Box(map, nDimension, halfLength, length, boundary)
end

mutable struct Thermo
    time::Float64
    iterTime::Int64
    Temp::Float64
end
function Thermo(initTemp::Float64)
    Thermo(0.0, 0, initTemp)
end

# Global type Universe
# Contain all the objects and universal properties
mutable struct Universe
    objs::Vector{Obj}
    fre::Float64
    box::Box
    thermo::Thermo
    cache::Dict{String, Union{Int64,Float64}}
    stop::Bool
end
function Universe(boundary, initTemp)
    box = Box(boundary)
    thermo = Thermo(initTemp)
    cache = Dict{String, Union{Int64,Float64}}()
    Universe(Vector{Obj}(), 0, box, thermo, cache, false)
end

# Methods of Universe
function Base.getindex(universe::Universe, n::Int64)
    universe.objs[n]
end
function Base.push!(universe::Universe, obj::Obj)
    push!(universe.objs, obj)
    universe.fre += obj.eventsContainer.fre
end
function Base.push!(universe::Universe, objs::Vector{T}) where {T <: Obj}
    for obj in objs
        push!(universe, obj)
    end
end
function Base.delete!(universe::Universe, obj::Obj)
    deleteat!(universe.objs, findfirst(member->member==obj,universe.objs))
    universe.fre -= obj.eventsContainer.fre
end
function Base.iterate(universe::Universe)
    iterate(universe.objs)
end
function Base.iterate(universe::Universe, n::Int64)
    iterate(universe.objs, n)
end
function Base.length(universe::Universe)
    length(universe.objs)
end

