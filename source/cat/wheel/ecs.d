module cat.wheel.ecs;

import cat.wheel.events;

/**
 * A handler for an Entity-Component System, which manages entities and components allowing delegates to be registered from them to
 * the main handler.
 */
class ECSHandler {

    /**
     * Construct a new ECS handler with no entities
     * Params:
     *   handler = The handler to register this ECS to
     */
    this(Handler handler) {
        _handler = handler;
    }

    /**
     * Register a delegate to the linked handler
     * Params:
     *   del = The delegate to register
     *   event = The event to run the delegate on
     */
    void register(void delegate(EventArgs) del, int event) {
        _handler.addDelegate(del, event);
    }

    Entity createEntity() {
        auto e = new Entity();
        _entities ~= e;
        return e;
    }

private:
    Handler _handler;

    Entity[] _entities;
}

class Entity {
    public Component[] components;
}

class Component {

    this(ECSHandler handler) {
        _handler = handler;
    }

private:
    ECSHandler _handler;
}