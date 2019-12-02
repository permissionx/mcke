#function FindNeighbourObjs(universe::Universe, obj::DefectObj)
#    universe.objs
#end

function FindNeighbourObjs(universe::Universe, obj::DefectObj)
    objs = Vector{DefectObj}()
    for dCellIndex in universe.cellContainer.dCellIndexs
        cellIndex = obj.cellIndex + dCellIndex
        try
            objs =vcat(objs, universe.cellContainer.cells[CartesianIndex(Tuple(cellIndex))].objs) 
        catch 
            continue
        end
        #objs = vcat(objs, theObjs) #need modify 
    end
    objs
end

function DCellIndexs(nDimension)
    dCellIndexs = Vector{Vector{Int64}}()
    dCellIndex = Vector{Int64}()
    IterDCellIndexs(dCellIndexs, dCellIndex, 1, nDimension)
    dCellIndexs
end


function IterDCellIndexs(dCellIndexs::Vector{Vector{Int64}}, dCellIndex::Vector{Int64},
                             d::Int64, nDimension::Int64)
    for dI in [-1,0,1]
        if d < nDimension
            IterDCellIndexs(dCellIndexs,vcat(dCellIndex,dI), d+1, nDimension)
        else
            push!(dCellIndexs, copy(vcat(dCellIndex,dI)))
        end
    end
end

