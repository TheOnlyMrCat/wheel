module cat.wheel.graphics;

import std.conv : to;
import std.string;
import derelict.sdl2.sdl;

import cat.wheel.except;
import cat.wheel.structs;

/**
 * Represents a window managed by SDL
 */
class Window {
public:

	/**
	 * Constructs a new wrapped SDL_Window struct.
	 * Params:
	 *   title = The title of the window, default ""
	 *   x = The initial x position of the window on the screen, from the left
	 *   y = The initial y position of the window on the screen, from the top
	 *   w = The initial width of the window
	 *   h = The initial height of the window
	 *   flags = A number of window flags to initialise the window with
	 */
	this(string title = "", int x = SDL_WINDOWPOS_UNDEFINED, int y = SDL_WINDOWPOS_UNDEFINED, int w = 0, int h = 0, uint flags = 0) {
		_window = SDL(SDL_CreateWindow(title.toStringz(), x, y, w, h, flags));
	}

	~this() nothrow {
		SDL_DestroyWindow(_window);
	}

	/**
	 * The x position of the managed window
	 */
	@property int x() nothrow {
		int *x;
		SDL_GetWindowPosition(_window, x, null);
		return *x;
	}

	///
	@property void x(int x) nothrow {
		SDL_SetWindowPosition(_window, x, this.y);
	}

	/**
	 * The y position of the managed window
	 */
	@property int y() nothrow {
		int *y;
		SDL_GetWindowPosition(_window, null, y);
		return *y;
	}

	///
	@property void y(int y) nothrow {
		SDL_SetWindowPosition(_window, this.x, y);
	}

	/**
	 * The width of the managed window
	 */
	@property int width() nothrow {
		int *w;
		SDL_GetWindowSize(_window, w, null);
		return *w;
	}

	///
	@property void width(int w) nothrow {
		SDL_SetWindowSize(_window, w, height);
	}

	/**
	 * The height of the managed window
	 */
	@property int height() nothrow {
		int *h;
		SDL_GetWindowSize(_window, null, h);
		return *h;
	}

	///
	@property void height(int h) nothrow {
		SDL_SetWindowSize(_window, width, h);
	}

	/**
	 * The title of the managed window
	 */
	@property string title() nothrow {
		return _title;
	}

	///
	@property void title(string t) nothrow {
		_title = t;
		SDL_SetWindowTitle(_window, _title.toStringz());
	}

	/**
	 * The wrapped window
	 */
	@property SDL_Window* window() nothrow {
		return _window;
	}

private:
	SDL_Window* _window;
	string _title;
}

class Graphics {
public:

	/**
	 * Creates a new wrapped SDL_Renderer
	 * Params:
	 *   w = The window to create the renderer for
	 *   flags = The flags to look for when initialising a renderer
	 *   index = The index of the renderer to initialise, leave blank (-1) for the first matching the specified flags
	 */
	this(Window w, uint flags = 0, int index = -1) {
		_renderer = SDL_CreateRenderer(w._window, index, flags);
	}

	~this() {
		SDL_DestroyRenderer(_renderer);
	}

	void drawPoint(Vector2 pos) {
		SDL_RenderDrawPoint(_renderer, pos.x, pos.y).check;
	}

	void drawPoints(Vector2[] points) {
		SDL_Point[] sdl = new SDL_Point[points.length];
		for (int i = 0; i < points.length; i++) {
			sdl[i] = cast(SDL_Point) points[i];
		}

		SDL_RenderDrawPoints(_renderer, sdl.ptr, points.length.to!int).check;
	}

	void drawLine(Vector2 pos1, Vector2 pos2) {
		SDL_RenderDrawLine(_renderer, pos1.x, pos1.y, pos2.x, pos2.y).check;
	}

	void drawLines(Vector2[2][] lines) {
		SDL_Point[] sdl = new SDL_Point[lines.length * 2];
		for (int i = 0; i < lines.length * 2; i++) {
			sdl[i] = cast(SDL_Point) lines[i/2][i%2];
		}

		SDL_RenderDrawLines(_renderer, sdl.ptr, sdl.length.to!int).check;
	}

	///
	@property clipRect() nothrow {
		return _clipRect;
	}

	///
	@property clipRect(Rect clip) nothrow {
		_clipRect = clip;
		return SDL_RenderSetClipRect(_renderer, &_clipRect.sdl);
	}

	///
	@property color() nothrow {
		return _drawColour;
	}

	///
	@property color(Color c) nothrow {
		_drawColour = c;
		return SDL_SetRenderDrawColor(_renderer, _drawColour.r, _drawColour.g, _drawColour.b, _drawColour.a);
	}

private:
	SDL_Renderer* _renderer;

	Rect _clipRect;
	Color _drawColour;
}