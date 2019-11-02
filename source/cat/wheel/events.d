module cat.wheel.events;

import std.string;
import std.array;
import core.sync.mutex;
import bindbc.sdl;

import cat.wheel.except;

/**
 * Initialize the SDL library. Call this once, and before anything else.
 * systems: The subsystems to initialize
 */
void initSDL(uint systems) {
	SDL_Init(systems).check;
}

/**
 * Initialize one or more subsystems of SDL.
 * systems: The subsystems to initialize
 */
void initSystem(uint systems) {
	SDL_InitSubSystem(systems).check;
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
 * Arguments to event handler delegates
 */
class EventArgs {}

/**
 * The argument to the default PUMP event
 */
class PumpEventArgs : EventArgs {
	package this(SDL_Event e) { event = e; }

	/**
	 * The event
	 */
	public SDL_Event event;
}

/**
 * Represents an SDL event handler, which controls the main thread and calls delegate functions specified by the program
 */
class Handler {
	/**
	 * Adds a delegate function to be called by this handler when a specific event occurs
	 */
	void addDelegate(void delegate(EventArgs) del, int event) nothrow @safe {
		_delegates[event] ~= del;
	}

	/**
	 * Forces the main loop to stop
	 */
	void stop() nothrow pure @safe {
		_doContinue = false;
	}

	/**
	 * Starts the main loop for this Handler. The loop will run until the stop function has been called
	 */
	void handle() {
		while (_doContinue) {
			runDelegates(ED_PRE_PUMP);

			_eventsSDL = _eventsSDL.init;
			auto appender = appender(_eventsSDL);

			SDL_Event e;
			while (SDL_PollEvent(&e)) {
				appender.put(e);

				runDelegates(ED_PUMP, new PumpEventArgs(e));
			}

			runDelegates(ED_POST_PUMP);

			const int currentTime = SDL_GetTicks();
			_deltaTime = _lastTick - currentTime;
			_lastTick = currentTime;

			runDelegates(ED_PRE_TICK);
			runDelegates(ED_TICK);
			runDelegates(ED_POST_TICK);
		}
	}

	/**
	 * Dispatches an event to be run by user-defined delegate functions
	 * event: Event UID
	 */
	void callEvent(uint event, EventArgs arg = new EventArgs()) {
		runDelegates(event, arg);
	}

	/**
	 * The amount of time it took between the previous frame and this frame
	 * This function should only be called on the main thread.
	 */
	@property time() nothrow @safe {
		return _deltaTime;
	}

	/**
	 * The SDL events that happened this frame.
	 * This function should only be called on the main thread.
	 */
	@property events() nothrow @safe {
		return _eventsSDL;
	}

private:
	void delegate(EventArgs)[][int] _delegates;

	void runDelegates(uint type, EventArgs args = new EventArgs()) {
		foreach (d; _delegates[type]) {
			d(args);
		}
	}

	shared(bool) _doContinue = true;
	shared(SDL_Event[]) _eventsSDL;

	int _deltaTime;
	int _lastTick;
}

enum : uint {
	ED_TICK = 0b000,
	ED_PRE_PUMP = 0b001,
	ED_PUMP = 0b010,
	ED_POST_PUMP = 0b011,
	ED_PRE_TICK = 0b100,
	ED_POST_TICK = 0b101
}