mutable struct Cell
    objs::Vector{DefectObj}
end

mutable struct CellContainer
    cells::Array{Cell}
    cellCutoff::Float64
    dCellIndexs::Vector{Vector{Int64}}
end





    