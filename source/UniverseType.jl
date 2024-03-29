# Universal properties
struct Map
    interstitialDirections::Vector{Vector{Int64}}
end
function Map(nDimension::Int64)
    Map(GenerateIntersitialDirections(nDimension))
end

struct Box 
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
    lastTime::Float64
    iterTime::Int64
    Temp::Float64
end
function Thermo(initTemp::Float64)
    Thermo(0.0, 0.0, 0, initTemp)
end

EventContainer{UniverseEvent}() = EventContainer{UniverseEvent}(0,[],[])

function CellContainer(box::Box, cellCutoff::Float64)
    nDimension = box.nDimension
    dCellIndexs = DCellIndexs(nDimension)
    lengths = Vector{Int64}(undef, nDimension)
    for d in 1:nDimension
        lo = fld(box.boundary[d,1],cellCutoff)
        hi = fld(box.boundary[d,2],cellCutoff)-1
        lengths[d] = hi-lo
    end
    cells = Array{Cell}(undef, Tuple(lengths))
    for index = 1:length(cells)
        cells[index] = Cell(Vector{DefectObj}())
    end
    CellContainer(cells, cellCutoff, dCellIndexs)
end

# Global type Universe
# Contain all the objects and universal properties
mutable struct Universe
    objs::Vector{DefectObj}
    cellContainer::CellContainer
    universeEventHolders::Vector{UniverseEventHolder}
    maxID::Int64
    fre::Float64
    box::Box
    thermo::Thermo
    dumpFileNames::Vector{String}
    cache::Dict{String, Union{Int64, Float64}}
    stop::Bool
end
function Universe(boundary, initTemp)
    box = Box(boundary)
    cellContainer = CellContainer(box, cellCutoff)
    thermo = Thermo(initTemp)
    universeEventContainer = EventContainer{UniverseEvent}()
    universeEventHolder = UniverseEventHolder(universeEventContainer)
    Universe(Vector{DefectObj}(), cellContainer, [universeEventHolder], 
            0, 0, box, thermo, 
            Vector{String}(), Dict{String, Union{Int64, Float64}}(), false)
end

# Methods of Universe
function Base.getindex(universe::Universe, n::Int64)
    universe.objs[n]
end
function Base.push!(universe::Universe, obj::DefectObj)
    universe.maxID += 1
    obj.id = universe.maxID
   # if obj.id == 3224
   #     push!(debug, obj)
   # end
    push!(universe.objs, obj)
    universe.fre += obj.eventContainer.fre
end
function Base.push!(universe::Universe, obj::UniverseEventHolder)
    push!(universe.universeEventHolders, obj)
    universe.fre += obj.eventContainer.fre
end
function Base.delete!(universe::Universe, obj::DefectObj)
    deleteat!(universe.objs, findfirst(member->member==obj,universe.objs))
    universe.fre -= obj.eventContainer.fre
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

