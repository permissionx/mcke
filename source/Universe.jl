using Distributions

#-- Events
# Neccessary Appendix
function Interact!(universe::Universe, events::Vector{T}, obj::Obj) where {T <: Event}
    enObjs = FindNeighbourObjs(universe, obj)
    for enObj in enObjs
        if enObj == obj
            continue
        end
        Interact!(universe, events, obj, enObj)
        if obj.dismissed
            break
        end
    end
end

function Introduce!(universe::Universe, events::Vector{T}, obj::Obj...) where {T <: Event}
    # Maybe dangerous here, because the other objs not examined if dismissed.
    # So, other objs have to be chosen from the universe, making sure the existing of the objs.
    for event in events
        if obj[1].dismissed
            return
        end
        _Execute!(universe, event, obj...)
    end
    Interact!(universe, events, obj[1])
end

function Introduce!(universe::Universe, events::Vector{T}, obj::Obj...) where {T <: HighLvlEvent}
    for event in events
        if obj[1].dismissed
            return
        end
        _Execute!(universe, event, obj...)
    end
end


# Process Controler
#- Choose event randomly
function ChooseRandom(universe::Universe)
    obj = ChooseRandomObj(universe)
    event = ChooseRandomEvent(obj)
    obj, event
end

function ChooseRandomObj(universe::Universe)
    criNum = rand(Uniform(0.0,universe.fre))
    countNum = 0.0
    for obj in universe
        countNum += obj.eventsContainer.fre
        if countNum >= criNum
            return obj
        end
    end
end

function ChooseRandomEvent(obj::Obj)
    criNum = rand(Uniform(0.0,obj.eventsContainer.fre))
    countNum = 0.0
    i = 1
    while true
        countNum += obj.eventsContainer.fres[i]
        if countNum >= criNum
            return obj.eventsContainer.events[i]
        end
        i += 1
    end
end

################
function dTime(universe::Universe)
    -log(rand())/universe.fre
end
################

#- evovle
function InitlUniverse()
    Universe(boundary, initTemp)
end

function EssentialEvents(universe::Universe)
    if length(universe) > 0
        obj, event = ChooseRandom(universe)
        Introduce!(universe, [event], obj)
    end
    universe.thermo.time += dTime(universe)
    universe.thermo.iterTime += 1
    if universe.thermo.time != Inf
        universe.thermo.lastTime = universe.thermo.time
    end
end

#- IO
function dump(universe::Universe, filename::String)
    # LAMMPS dump format, for ovito reading.
    # Need to update to fit any obj attributs range.
    if universe.thermo.iterTime == 0
        openStype = "w"
    else
        openStype = "a+"
    end
    open(filename, openStype) do io
        write(io,"ITEM: TIMESTEP\n$(universe.thermo.iterTime)\n")
        write(io,"ITEM: NUMBER OF ATOMS\n$(length(universe))\n")
        write(io,"ITEM: BOX BOUNDS ")
        for _ in 1:universe.box.nDimension
            write(io,"pp ")
        end
        write(io,"\n")
        for d in 1:universe.box.nDimension
            write(io, "$(universe.box.boundary[d,1]) $(universe.box.boundary[d,2])\n")
        end
        write(io, "ITEM: ATOMS id type ")
        dimensionName = ("x","y","z")
        for d in 1:universe.box.nDimension
            write(io, "$(dimensionName[d]) ")
        end
        write(io, "size\n")
        for obj in universe
            write(io, "$(obj.id) $(obj.typeNum) ")
            for d in 1:universe.box.nDimension
                write(io, "$(obj.position[d]) ") 
            end
            write(io, "$(obj.size)\n")
        end
    end
end





