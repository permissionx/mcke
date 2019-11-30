function DVector(obj1::Obj, obj2::Obj, universe::Universe)   
    dr = obj2.position - obj1.position
    #for d in 1:universe.box.nDimension
    #    if dr[d] >= universe.box.halfLength[d]
    #        dr[d] -= universe.box.length[d]
    #    elseif dr[d] < -universe.box.halfLength[d]
    #        dr[d] += universe.box.length[d]
    #    end
    #end
    dr
end

function Distance(obj1::Obj, obj2::Obj, universe::Universe)
    dVector = DVector(obj1, obj2, universe)
    distance = 0.0
    for d in 1:universe.box.nDimension
        distance += dVector[d]^2
    end
    return distance ^= 0.5
end

function Shift!(obj::Obj, dr::Vector{Int64}, universe::Universe)
    obj.position += dr
    for d in 1:universe.box.nDimension
        if obj.position[d] < universe.box.boundary[d,1]
            Introduce!(universe, [Disappear()], obj)
            #obj.position[d] += universe.box.length[d]
        elseif obj.position[d] >= universe.box.boundary[d,2]
            #obj.position[d] -= universe.box.length[d]
            Introduce!(universe, [Disappear()], obj)
        end
    end
end