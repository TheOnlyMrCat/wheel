module cat.wheel.structs;

import derelict.sdl2.sdl;

/**
 * A rectangle.
 *
 * That's it.
 *
 * Nothing else.
 *
 * It's a rectangle, what more do you want?
 */
struct Rect {

    /**
     * The wrapped SDL rectangle
     */
    SDL_Rect sdl;

    alias sdl this;
}

/**
 * An RGBA colour
 */
struct Color {
    /// The red value of the color
    ubyte r;

    /// The green value of the color
    ubyte g;

    /// The blue value of the color
    ubyte b;

    /// The transparency of the color, dependent on the blend mode used
    ubyte a;
}
/**
 * A 2-dimensional vector
 */
struct Vector2 {
    int x, y;
}

/**
 * A 3-dimensional vector
 */
struct Vector3 {
    int x, y, z;
}