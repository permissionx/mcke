using Distributions

#-- Events
function DefineUniverseEvent(universe::Universe, event::IntroduceRandomDefects, fre::Float64)
    eventContainer = universe.universeEventHolders[1].eventContainer
    push!(eventContainer.events, event)
    newFres = vcat(eventContainer.fres, fre)
    Introduce!(universe, [ReFres(newFres)], universe.universeEventHolders[1])
end

# Neccessary Appendix
function Interact!(universe::Universe, events::Vector{T}, obj::DefectObj) where {T <: ObjEvent}
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


function Introduce!(universe::Universe, events::Vector{T}, obj::DefectObj...) where {T <: ObjEvent}
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

function Introduce!(universe::Universe, events::Vector{T}, obj::DefectObj...) where {T <: HighLvlEvent}
    for event in events
        if obj[1].dismissed
            return
        end
        _Execute!(universe, event, obj...)
    end
end

function Introduce!(universe::Universe, events::Vector{T}, obj::DefectObj...) where {T <: UniverseEvent}
    for event in events
        _Execute!(universe, event, obj...)
    end
end

function Introduce!(universe::Universe, events::Vector{T}, obj::UniverseObj...) where {T <: Event}
    for event in events
        _Execute!(universe, event, obj...)
    end
end
Introduce!(universe::Universe, events::Vector{UniverseEvent}) = Introduce!(universe, events, UniverseObj(EventContainer{UniverseEvent}()))


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
    for obj in vcat(universe.objs, universe.universeEventHolders)
        countNum += obj.eventContainer.fre
        if countNum >= criNum
            return obj
        end
    end
end

function ChooseRandomEvent(obj::Obj)
    criNum = rand(Uniform(0.0,obj.eventContainer.fre))
    countNum = 0.0
    i = 1
    while true
        countNum += obj.eventContainer.fres[i]
        if countNum >= criNum
            return obj.eventContainer.events[i]
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
    # Need to be fixed when len(objs) == 0: try except non obj
    obj, event = ChooseRandom(universe)
    Introduce!(universe, [event], obj)
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





