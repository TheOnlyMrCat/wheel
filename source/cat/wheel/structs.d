module cat.wheel.structs;

import bindbc.sdl;

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

    /**
     * Constructs the Rect from four integers
     */
    this(int x, int y, int w, int h) {
        sdl.x = x;
        sdl.y = y;
        sdl.w = w;
        sdl.h = h;
    }

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
    ///
    int x, y;
}

struct Vector2F {
    float x, y;
}

/**
 * A 3-dimensional vector
 */
struct Vector3 {
    ///
    int x, y, z;
}

struct Vector3F {
    float x, y, z;
}