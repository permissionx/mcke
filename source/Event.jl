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
    Shift!(obj, event.dr, universe.box)
end

#- Resize
function _Execute!(universe::Universe, event::Resize, obj::Obj)
    obj.size = event.newSize
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
    shiftVector = Int64.(round.(DVector(bigObj, smallObj, universe.box).*(smallObj.size/(bigObj.size+smallObj.size))))
    newSize = bigObj.size+smallObj.size
    Introduce!(universe, [Disappear()], smallObj)
    Introduce!(universe, [Move(shiftVector), Resize(newSize)] , bigObj)
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
    shiftVector = -Int64.(round.(DVector(bigObj, smallObj, universe.box).*(smallObj.size/(bigObj.size+smallObj.size))))
    newSize = bigObj.size-smallObj.size
    Introduce!(universe, [Disappear()], smallObj)
    Introduce!(universe, [Move(shiftVector), Resize(newSize)] , bigObj)
end

# Interact
function Interact!(universe::Universe, events::Vector{Event}, obj::Obj, enObj::Obj)
end

function Interact!(universe::Universe, events::Vector{T3}, obj::T1, enObj::T2) where {T1<:Union{Vacancy, Interstitial}, T2<:Union{Vacancy, Interstitial}, T3<:Event}
    distance = Distance(obj, enObj, universe.box)
    if distance <= obj.size + enObj.size
        Introduce!(universe, [Swallow()], obj, enObj)
    end
end

function Interact!(universe::Universe, events::Vector{Disappear}, obj::Obj, enObj::Obj) 
end
