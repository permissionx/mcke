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
#########################

function GenerateNeccessaryEvent()
    function Should(universe::Universe)
        true
    end
    function Intro(universe::Universe)
        universe.thermo.iterTime += 1
    end
    UniverseEvent(Should, Intro)
end

function addUniverseEvents(events::Vector{UniverseEvent})
    neccessaryEvent = GenerateNeccessaryEvent()
    Vector{UniverseEvent}(vcat([neccessaryEvent], events))
end

################

#- Main
function Evolve(universe::Universe, universeEvents::Vector{UniverseEvent})
    while true
        
        for n = 1:length(universeEvents)   
            if universeEvents[n].should(universe)
                universeEvents[n].introduce!(universe)
            end
        end

        if universe.stop
            break
        end
        obj, event = ChooseRandom(universe)
        Introduce!(universe, [event], obj)
    end
end



