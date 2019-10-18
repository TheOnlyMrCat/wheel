module cat.wheel.events;

import std.string;
import std.container.array;
import core.sync.mutex;
import derelict.sdl2.sdl;

public import cat.wheel.except;

/**
 * Initialize the SDL library. Call this once, and before anything else.
 * systems: The subsystems to initialize
 */
void initSDL(uint systems) {
	DerelictSDL2.load();

	if (SDL_Init(systems) != 0) {
		throw new SDLException(cast(string) SDL_GetError().fromStringz());
	}
}

/**
 * Initialize one or more subsystems of SDL.
 * systems: The subsystems to initialize
 */
void initSystem(uint systems) {
	if (SDL_InitSubSystem(systems) != 0) {
		throw new SDLException(cast(string) SDL_GetError().fromStringz());
	}
}

/**
 * Shuts down the SDL library and all initialized subsystems
 */
void quitSDL() {
	SDL_Quit();
}

/**
 * Shuts down specific subsystems of SDL
 * systems: The subsystems to quit
 */
void quitSystem(uint systems) {
	SDL_QuitSubSystem(systems);
}

/**
 * Represents an SDL event handler, which controls the main thread and calls delegate functions specified by the program
 */
class Handler {
	/**
	 * Adds a delegate function to be called by this handler when a specific event occurs
	 */
	void addDelegate(void delegate() nothrow del, int event) nothrow {
		tick[event] ~= del;
	}

	/**
	 * Forces the main loop to stop
	 */
	void stop() nothrow {
		_doContinue = false;
	}

	/**
	 * Starts the main loop for this Handler. The loop will run until the stop function has been called
	 */
	void handle() {
		while (_doContinue) {
			runDelegates(DefaultEvents.PRE_PUMP);

			_events = _events.init;
			auto appender = _events.appender();

			SDL_Event e;
			while (SDL_PollEvent(&e)) {
				appender.put(e);

				runDelegates(DefaultEvents.PUMP);
			}

			runDelegates(DefaultEvents.POST_PUMP);

			immutable(int) currentTime = SDL_GetTicks();
			_deltaTime = _lastTick - currentTime;
			_lastTick = currentTime;

			runDelegates(DefaultEvents.TICK);
		}
	}

	/**
	 * Dispatches an event to be run by user-defined delegate functions
	 * event: Event UID
	 */
	void callEvent(int event) {
		runDelegates(event);
	}

	/**
	 * The amount of time it took between the previous frame and this frame
	 * This function should only be called on the main thread.
	 */
	@property time() {
		return _deltaTime;
	}

	/**
	 * The SDL events that happened this frame.
	 * This function should only be called on the main thread.
	 */
	@property events() {
		return _eventsSDL;
	}
private:
	void delegate()[][int] _tick;

	void runDelegates(int type) nothrow {
		foreach (d; _tick[type]) {
			d();
		}
	}

	shared(bool) _doContinue = true;

	shared(bool) lockEvents;
	shared(SDL_Event[]) _eventsSDL;

	int[] _events;
	int _deltaTime;

	int _lastTick;
}

enum DefaultEvents {
	PRE_PUMP = 1,
	PUMP = 2,
	POST_PUMP = 3,
	TICK = 4
}