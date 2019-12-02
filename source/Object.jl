function CreateRandomVacancy(universe::Universe, maxSize::Int64)
    position = [rand(universe.box.boundary[d,1]:universe.box.boundary[d,2]) for d in 1:universe.box.nDimension]
    size = rand(1:maxSize)
    Vacancy(position, size)
end

function CreateRandomInterstitial(universe::Universe, maxSize::Int64)
    position = [rand(universe.box.boundary[d,1]:universe.box.boundary[d,2]) for d in 1:universe.box.nDimension]
    size = rand(1:maxSize)
    direction = sample(universe.box.map.interstitialDirections)
    Interstitial(position, size, direction)
end

function GenerateIntersitialDirections(nDimension::Int64)
    nDimension -= 1
    directions = Vector{Vector{Int64}}()
    direction = Vector{Int64}(undef, nDimension)
    IterIntersitialDirections!(directions, direction, 1, nDimension)
    vcat.([1],directions)
end

function IterIntersitialDirections!(directions::Vector{Vector{Int64}}, 
    direction::Vector{Int64}, d::Int64, nDimension::Int64)
    for i in [1,-1]
        direction[d] = i
        if d < nDimension
            IterIntersitialDirections!(directions, direction, d+1, nDimension)
        end
        if d == nDimension
            push!(directions, deepcopy(direction))
        end
    end
end

function DeleteCell!(universe::Universe, obj::DefectObj)
    cellIndex = obj.cellIndex
    cell = universe.cellContainer.cells[CartesianIndex(Tuple(cellIndex))]
    filter!(o->o!=obj,cell.objs)
end

function ReCell!(universe::Universe, obj::DefectObj)
    box = universe.box
    cellContainer = universe.cellContainer
    cellIndex = Vector{Int64}(undef, box.nDimension)
    #if universe.thermo.iterTime == 503
    #    println(obj.id,"     ########")
    #end
    #if universe.thermo.iterTime > 0# == 507
    #    println(debug[1] in universe.cellContainer.cells[1,9,7].objs,"  @      ", universe.thermo.iterTime)
    #end
    for d in 1:box.nDimension
        cellIndex[d] = fld(obj.position[d] - box.boundary[d,1], cellContainer.cellCutoff)
        if cellIndex[d] >= size(cellContainer.cells)[d] 
            cellIndex[d] -= 2
        end
        if cellIndex[d] < 0
            cellIndex[d] = 0
        end
        cellIndex[d] += 1
    end
    if cellIndex != obj.cellIndex
        if obj.cellIndex != [] 
            DeleteCell!(universe, obj)
        end
        push!(cellContainer.cells[CartesianIndex(Tuple(cellIndex))].objs, obj)
        obj.cellIndex = cellIndex
    end
    #if universe.thermo.iterTime > 0 # == 507
    #    println(debug[1] in universe.cellContainer.cells[1,9,7].objs,"    @    ", universe.thermo.iterTime)
    #end
end
