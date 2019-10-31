module cat.wheel.keysym;

import bindbc.sdl;

/**
 * Key information for use in key events
 */
struct Keysym {
    /// The virtual key involved in the event
    SDL_Keycode code;

    /// The modifiers being applied to the key
    SDL_Keymod modifiers;
}