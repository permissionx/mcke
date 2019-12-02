#- Disappear
function _Execute!(universe::Universe, event::Disappear, obj::DefectObj)
    #if obj.id == 3224
    #    println(obj)
    #    for cell in universe.cellContainer.cells
    #        if obj in cell.objs
    #            println("inininininin")
    #            println(universe.thermo.iterTime)
    #        end
    #    end
    #end
  # if universe.thermo.iterTime > 500
  # if debug[1] == obj 
  #     println(universe.thermo.iterTime, " Dis")
  # end
  # end
    DeleteCell!(universe, obj)
    delete!(universe, obj)
    obj.dismissed = true
end

#- Appear
function _Execute!(universe::Universe, event::Appear, obj::DefectObj)
    #if universe.thermo.iterTime > 500
    #if debug[1] == obj 
    #    println(universe.thermo.iterTime)
    #end
    #end
    push!(universe, obj)
    ReCell!(universe, obj)
end

#- Move
function _Execute!(universe::Universe, event::Move, obj::DefectObj)
    #if universe.thermo.iterTime > 500
    #if debug[1] == obj 
    #    println(universe.thermo.iterTime," Move")
    #end
    #end
    Shift!(obj, event.dr, universe)
    ReCell!(universe, obj)
end

#- ReSize
function _Execute!(universe::Universe, event::ReSize, obj::Vacancy)
    newFres = obj.eventContainer.fres*(obj.size/event.newSize)^3
    Introduce!(universe, [ReFres(newFres)], obj)
    obj.size = event.newSize
end
function _Execute!(universe::Universe, event::ReSize, obj::Interstitial)
    newFres = obj.eventContainer.fres*(obj.size/event.newSize)^(1/10)
    Introduce!(universe, [ReFres(newFres)], obj)
    obj.size = event.newSize
end

#- ReFres
function _Execute!(universe::Universe, event::ReFres, obj::Obj)
    newFre = sum(event.newFres)
    universe.fre = universe.fre - obj.eventContainer.fre + newFre
    obj.eventContainer.fres = event.newFres
    obj.eventContainer.fre = newFre
end

#- RediRsection
function _Execute!(universe::Universe, event::ReDirection, obj::Interstitial)
    newEvent = ReDirection(obj.direction)
    push!(obj.eventContainer.events, newEvent)
    filter!(x-> x.newDirection = event.newDirection, obj.eventContainer.events)
    obj.direction = event.newDirection
end

#- Slip
function _Execute!(universe::Universe, event::Slip, obj::Interstitial)
    Introduce!(universe, [Move(obj.direction*event.upAndDown)], obj)
end


#- Swallow
function _Execute!(universe::Universe, event::Swallow, obj1::T, obj2::T) where {T<:Obj}
    #if obj2.id == 3224
    #    if obj2 in universe.cellContainer.cells[1,9,7].objs
    #        println("true")
    #    end
    #    if obj2 in universe
    #        println("ttt")
    #    end
    #    println(obj2)
    #    sdf
    #end
    # Same obj type
    if obj1.size >= obj2.size
        bigObj = obj1
        smallObj = obj2
    else
        bigObj = obj2
        smallObj = obj1
    end
    
    shiftVector = Int64.(round.(DVector(bigObj, smallObj, universe).*(smallObj.size/(bigObj.size+smallObj.size))))
    newSize = bigObj.size+smallObj.size
    Introduce!(universe, [Disappear()], smallObj)
    Introduce!(universe, [Move(shiftVector), ReSize(newSize)] , bigObj)
end

function _Execute!(universe::Universe, event::Swallow, obj1::T1, obj2::T2) where {T1<:Obj, T2<:Obj}
    # Different obj type
    if obj1.size > obj2.size
        bigObj = obj1
        smallObj = obj2
    elseif obj1.size < obj2.size
        bigObj = obj2
        smallObj = obj1
    else
        Introduce!(universe, [Disappear()], obj1)
        Introduce!(universe, [Disappear()], obj2)
        return
    end
    shiftVector = -Int64.(round.(DVector(bigObj, smallObj, universe).*(smallObj.size/(bigObj.size+smallObj.size))))
    newSize = bigObj.size-smallObj.size
    Introduce!(universe, [Disappear()], smallObj)
    Introduce!(universe, [Move(shiftVector), ReSize(newSize)] , bigObj)
end

# Interact
function Interact!(universe::Universe, events::Vector{ObjEvent}, obj::DefectObj, enObj::DefectObj)
end

function Interact!(universe::Universe, events::Vector{Disappear}, obj::T1, enObj::T2) where {T1<:DefectObj, T2<:DefectObj}
end

function Interact!(universe::Universe, events::Vector{T3}, obj::T1, enObj::T2) where {T1<:DefectObj, T2<:DefectObj, T3<:ObjEvent}
    distance = Distance(obj, enObj, universe)
    if distance <= (obj.size/4.0/3.14*3)^(1/3) + (enObj.size/4.0/3.14*3)^(1/3)
        Introduce!(universe, [Swallow()], obj, enObj)
    end
end

# Universe Evnets
function _Execute!(universe::Universe, event::IntroduceRandomDefects, obj::UniverseEventHolder...)
    for i in 1:event.numDefects
        defect = sample([1,2])
        if defect == 1
            Introduce!(universe, [Appear()], CreateRandomVacancy(universe, event.maxSize))
            #Introduce!(universe, [Appear()], CreateRandomInterstitial(universe, event.maxSize))
        else
            #Introduce!(universe, [Appear()], CreateRandomVacancy(universe, event.maxSize))
            Introduce!(universe, [Appear()], CreateRandomInterstitial(universe, event.maxSize))
        end
    end
end

