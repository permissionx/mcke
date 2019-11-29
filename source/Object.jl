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


function IntroduceRandomDefects(universe::Universe, numDefects::Int64, maxSize::Int64)
    for i in 1:numDefects
        defect = sample([1,2])
        if defect == 1
            Introduce!(universe, [Appear()], CreateRandomVacancy(universe, maxSize))
        else
            Introduce!(universe, [Appear()], CreateRandomInterstitial(universe, maxSize))
        end
    end
end


function generateIntersitialDirections(nDimension::Int64)
    nDimension -= 1
    directions = Vector{Vector{Int64}}()
    direction = Vector{Int64}(undef, nDimension)
    iterIntersitialDirections!(directions, direction, 1, nDimension)
    vcat.([1],directions)
end

function iterIntersitialDirections!(directions::Vector{Vector{Int64}}, 
    direction::Vector{Int64}, d::Int64, nDimension::Int64)
    for i in [1,-1]
        direction[d] = i
        if d < nDimension
            iterIntersitialDirections!(directions, direction, d+1, nDimension)
        end
        if d == nDimension
            push!(directions, deepcopy(direction))
        end
    end
end
