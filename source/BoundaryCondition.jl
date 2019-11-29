function DVector(obj1::Obj, obj2::Obj, box::Box)   
    dr = obj2.position - obj1.position
    for d in 1:box.nDimension
        if dr[d] >= box.halfLength[d]
            dr[d] -= box.length[d]
        elseif dr[d] < -box.halfLength[d]
            dr[d] += box.length[d]
        end
    end
    dr
end

function Distance(obj1::Obj, obj2::Obj, box::Box)
    dVector = DVector(obj1::Obj, obj2::Obj, box::Box)
    distance = 0.0
    for d in 1:box.nDimension
        distance += dVector[d]^2
    end
    return distance ^= 0.5
end

function Shift!(obj::Obj, dr::Vector{Int64}, box::Box)
    obj.position += dr
    for d in 1:box.nDimension
        if obj.position[d] < box.boundary[d,1]
            obj.position[d] += box.length[d]
        elseif obj.position[d] >= box.boundary[d,2]
            obj.position[d] -= box.length[d]
        end
    end
end