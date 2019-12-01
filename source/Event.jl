#- Disappear
function _Execute!(universe::Universe, event::Disappear, obj::Obj)
    delete!(universe, obj)
    obj.dismissed = true
end

#- Appear
function _Execute!(universe::Universe, event::Appear, obj::Obj)
    push!(universe, obj)
end

#- Move
function _Execute!(universe::Universe, event::Move, obj::Obj)
    Shift!(obj, event.dr, universe)
end

#- ReSize
function _Execute!(universe::Universe, event::ReSize, obj::Vacancy)
    newFres = obj.eventsContainer.fres*(obj.size/event.newSize)^3
    Introduce!(universe, [ReFres(newFres)], obj)
    obj.size = event.newSize
end
function _Execute!(universe::Universe, event::ReSize, obj::Interstitial)
    newFres = obj.eventsContainer.fres*(obj.size/event.newSize)^(1/10)
    Introduce!(universe, [ReFres(newFres)], obj)
    obj.size = event.newSize
end

#- ReFres
function _Execute!(universe::Universe, event::ReFres, obj::Obj)
    newFre = sum(event.newFres)
    universe.fre = universe.fre - obj.eventsContainer.fre + newFre
    obj.eventsContainer.fres = event.newFres
    obj.eventsContainer.fre = newFre
end

#- RediRsection
function _Execute!(universe::Universe, event::ReDirection, obj::Interstitial)
    newEvent = ReDirection(obj.direction)
    push!(obj.eventsContainer.events, newEvent)
    filter!(x-> x.newDirection = event.newDirection, obj.eventsContainer.events)
    obj.direction = event.newDirection
end

#- Slip
function _Execute!(universe::Universe, event::Slip, obj::Interstitial)
    Introduce!(universe, [Move(obj.direction*event.upAndDown)], obj)
end

#- Swallow
function _Execute!(universe::Universe, event::Swallow, obj1::T, obj2::T) where {T<:Obj}
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
function Interact!(universe::Universe, events::Vector{Event}, obj::Obj, enObj::Obj)
end

function Interact!(universe::Universe, events::Vector{Disappear}, obj::Obj, enObj::Obj) 
end

function Interact!(universe::Universe, events::Vector{T3}, obj::T1, enObj::T2) where {T1<:Union{Vacancy, Interstitial}, T2<:Union{Vacancy, Interstitial}, T3<:Event}
    distance = Distance(obj, enObj, universe)
    if distance <= (obj.size/4.0/3.14*3)^(1/3) + (enObj.size/4.0/3.14*3)^(1/3)
        Introduce!(universe, [Swallow()], obj, enObj)
    end
end

