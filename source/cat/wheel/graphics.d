module cat.wheel.graphics;

import std.conv : to;
import std.string;
import bindbc.sdl;

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
	this(
		string title = "",
		int x = SDL_WINDOWPOS_UNDEFINED,
		int y = SDL_WINDOWPOS_UNDEFINED,
		int w = 0,
		int h = 0,
		SDL_WindowFlags flags = cast(SDL_WindowFlags) 0)
	{
		_window = SDL_CreateWindow(title.toStringz(), x, y, w, h, flags).objCheck;
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

/// Wrapper for an SDL_Surface
struct Surface {
	SDL_Surface *sdl;

	~this() {
		if (sdl != null) SDL_FreeSurface(sdl);
	}
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
	this(Window w, SDL_RendererFlags flags = cast(SDL_RendererFlags) 0, int index = -1) {
		_renderer = SDL_CreateRenderer(w._window, index, flags).objCheck;
	}

	/**
	 * Creates a software SDL renderer
	 * Params:
	 *   s = The surface for this renderer to draw to
	 */
	this(Surface s) {
		_renderer = SDL_CreateSoftwareRenderer(s.sdl).objCheck;
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

	void drawRect(Rect rect) {
		const(SDL_Rect) c = rect.sdl;
		SDL_RenderDrawRect(_renderer, &c).check;
	}

	void drawRects(Rect[] rects) {
		SDL_Rect[] sdl;
		for (int i = 0; i < rects.length; i++) {
			sdl[i] = rects[i].sdl;
		}

		const(SDL_Rect)[] sdlc = sdl;
		SDL_RenderDrawRects(_renderer, sdlc.ptr, sdl.length.to!int).check;
	}

	void fillRect(Rect rect) {
		const(SDL_Rect) c = rect.sdl;
		SDL_RenderFillRect(_renderer, &c).check;
	}

	void fillRects(Rect[] rects) {
		SDL_Rect[] sdl;
		for (int i = 0; i < rects.length; i++) {
			sdl[i] = rects[i].sdl;
		}

		const(SDL_Rect)[] sdlc = sdl;
		SDL_RenderFillRects(_renderer, sdlc.ptr, sdl.length.to!int).check;
	}

	void drawTexture(SDL_Texture* t, Rect src, Rect dest) {
		SDL_RenderCopy(_renderer, t, &src.sdl, &dest.sdl);
	}

	SDL_Texture* createTextureFrom(Surface s) {
		return SDL_CreateTextureFromSurface(_renderer, s.sdl).objCheck;
	}

	void render() {
		SDL_RenderPresent(_renderer);
	}

	void clear() {
		SDL_RenderClear(_renderer).check;
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

	/// The renderer
	@property renderer() nothrow {
		return _renderer;
	}

private:
	SDL_Renderer* _renderer;

	Rect _clipRect;
	Color _drawColour;
}