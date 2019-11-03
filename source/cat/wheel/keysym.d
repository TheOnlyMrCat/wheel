module cat.wheel.keysym;

import bindbc.sdl;

import cat.wheel.structs;

/**
 * Key information for use in key events
 */
struct Keysym {
    /// The virtual key involved in the event
    SDL_Keycode code;

    /// The modifiers being applied to the key
    SDL_Keymod modifiers;
}

/**
 * Mouse information for use in mouse button events
 */
struct MouseButton {
    /// The mouse instance ID
    uint instance;

    /// The button modified
    ubyte button;

    static if (sdlSupport == SDLSupport.sdl200) {
        ///
        ubyte padding;
    } else {
        /// The number of times the mouse has been clicked in quick succession
        ubyte clicks;
    }

    /// The position relative to the window
    Vector2 position;
}

/**
 * Mouse information for use in mouse motion events
 */
struct MouseMotion {
    /// The mouse instance ID
    uint instance;

    /// Bitmask of the mouse state
    uint state;

    /// The new position relative to the window
    Vector2 position;

    /// The change in position relative to the window
    Vector2 motion;
}

/**
 * Mouse information for use in mouse wheel events
 */
struct MouseWheel {
    /// The mouse instance ID
    uint instance;

    /**
     * The amount scrolled
     * X: Positive to the right, negative to the left
     * Y: Positive up, negative down
     */
    Vector2 delta;

    static if (sdlSupport >= SDLSupport.sdl204) {
        /// Whether it's reversed or not
        int direction;
    }
}