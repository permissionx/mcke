module OpenBoundaryCondition
    export DVector, Distance, Shift!

    function DVector(obj1::Base.Main.DefectObj, obj2::Base.Main.DefectObj, universe::Base.Main.Universe)   
        dr = obj2.position - obj1.position
        dr
    end

    function Distance(obj1::Base.Main.DefectObj, obj2::Base.Main.DefectObj, universe::Base.Main.Universe)
        dVector = DVector(obj1, obj2, universe)
        distance = 0.0
        for d in 1:universe.box.nDimension
            distance += dVector[d]^2
        end
        return distance = distance^0.5
    end

    function Shift!(obj::Base.Main.DefectObj, dr::Base.Main.Vector{Int64}, universe::Base.Main.Universe)
        obj.position += dr
        for d in 1:universe.box.nDimension
            if obj.position[d] < universe.box.boundary[d,1]
                Base.Main.Introduce!(universe, [Base.Main.Disappear()], obj)
                #obj.position[d] += universe.box.length[d]
            elseif obj.position[d] >= universe.box.boundary[d,2]
                #obj.position[d] -= universe.box.length[d]
                Base.Main.Introduce!(universe, [Base.Main.Disappear()], obj)
            end
        end
    end
end

module PPPBoundaryCondition
    export DVector, Distance, Shift!

    function DVector(obj1::Base.Main.DefectObj, obj2::Base.Main.DefectObj, universe::Base.Main.Universe)   
        dr = obj2.position - obj1.position
        for d in 1:universe.box.nDimension
            if dr[d] >= universe.box.halfLength[d]
                dr[d] -= universe.box.length[d]
            elseif dr[d] < -universe.box.halfLength[d]
                dr[d] += universe.box.length[d]
            end
        end
        dr
    end

    function Distance(obj1::Base.Main.DefectObj, obj2::Base.Main.DefectObj, universe::Base.Main.Universe)
        dVector = DVector(obj1, obj2, universe)
        distance = 0.0
        for d in 1:universe.box.nDimension
            distance += dVector[d]^2
        end
        return distance = distance^0.5
    end

    function Shift!(obj::Base.Main.DefectObj, dr::Base.Main.Vector{Int64}, universe::Base.Main.Universe)
        obj.position += dr
        for d in 1:universe.box.nDimension
            if obj.position[d] < universe.box.boundary[d,1]
                obj.position[d] += universe.box.length[d]
            elseif obj.position[d] >= universe.box.boundary[d,2]
                obj.position[d] -= universe.box.length[d]
            end
        end
    end
end