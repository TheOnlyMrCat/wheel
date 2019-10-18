module cat.wheel.graphics;

import std.string;
import derelict.sdl2.sdl;

import cat.wheel.except;

/**
 * Represents a window managed by SDL
 */
class Window {
public:

	/**
	 * Creates an empty window with a blank title, undefined coordinates, no width, and no height
	 * title: The title of the window
	 * x: The X position of the window
	 * y: The Y position of the window
	 * w: The width of the window
	 * h: The height of the window
	 * flags: A number of SDL window flags, OR'd together.
	 */
	this(string title = "", int x = SDL_WINDOWPOS_UNDEFINED, int y = SDL_WINDOWPOS_UNDEFINED, int w = 0, int h = 0, uint flags = 0) {
		_window = SDL(SDL_CreateWindow(title.toStringz(), x, y, w, h, flags));
	}

	~this() nothrow {
		SDL_DestroyRenderer(_renderer);
		SDL_DestroyWindow(_window);
	}

	/**
	 * Creates a renderer for the managed window. This function must be called before any graphical functions are called.
	 * flags: A number of SDL renderer flags, OR'd together
	 * index: The rendering driver to initialize. Leave blank to choose automatically
	 */
	void create(uint flags, int index = -1) {
		_renderer = SDL(SDL_CreateRenderer(_window, index, flags));
		_rendererMade = true;
	}

	/**
	 * The x position of the managed window
	 */
	@property int x() nothrow {
		int *x;
		SDL_GetWindowPosition(_window, x, null);
		return *x;
	}

	/***/
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

	/***/
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

	/***/
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

	/***/
	@property void height(int h) nothrow {
		SDL_SetWindowSize(_window, width, h);
	}

	/**
	 * The title of the managed window
	 */
	@property string title() nothrow {
		return title;
	}

	/***/
	@property void title(string t) nothrow {
		title = t;
		SDL_SetWindowTitle(_window, title.toStringz());
	}

private:
	SDL_Window* _window;

	SDL_Renderer* _renderer;
	bool _rendererMade;

	string _title;

	void check() {
		if (!_rendererMade) throw new Exception("Renderer hasn't been initialized yet");
	}
}