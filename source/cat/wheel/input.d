module cat.wheel.input;

import std.algorithm.searching;
import core.vararg;
import bindbc.sdl;

public import cat.wheel.events;
import cat.wheel.keysym;
import cat.wheel.structs;

/**
 * Arguments to keyboard events
 */
class KeyboardEventArgs : EventArgs {
	package this(Keysym s) { sym = s; }

	/// The key involved in the event
	public const(Keysym) sym;
}

/**
 * Arguments to events involving mouse buttons
 */
class MouseButtonEventArgs : EventArgs {
	package this(MouseButton m) { button = m; }

	/// The mouse button involved in the event
	public const(MouseButton) button;
}

/**
 * The argument to the mouse movement event
 */
class MouseMotionEventArgs : EventArgs {
	package this(MouseMotion m) { motion = m; }

	/// The mouse motion data for the event
	public const(MouseMotion) motion;
}

/**
 * The argument to the mouse wheel event
 */
class MouseWheelEventArgs : EventArgs {
	package this(MouseWheel m) { wheel = m; }

	/// The mouse wheel data for the event
	public const(MouseWheel) wheel;
}

/**
 * An input handler, which keeps track of what inputs are being held, pressed, released, etc.
 * Has to be registered to an event handler
 */
class InputHandler {

	/// Exists for unit testing purposes
	private this() {}

	/**
	 * Constructs an input handler from an SDL handler, which it attaches delegates to.
	 */
	this(Handler h) nothrow {
		_handler = h;

		_handler.addDelegate((EventArgs) => nextFrame(_handler.time), ED_PRE_PUMP);

		_handler.addDelegate((EventArgs arg) {
			if (arg.classinfo == typeid(PumpEventArgs)) store(*(cast(SDL_Event*) arg));
		}, ED_PUMP);

		_handler.addDelegate((EventArgs) => pumpEvents(), ED_PRE_TICK);
	}

	int getHeldFor(Keysym key) {
		return _heldKeys[key];
	}

private:
	Handler _handler;

	Keysym[] _pressedKeys;
	int[Keysym] _heldKeys;
	Keysym[] _releasedKeys;

	MouseButton[] _mouseButtonsPressed;
	MouseButton[] _mouseButtonsReleased;
	MouseMotion[] _mouseMotionEvents;
	MouseWheel[] _mouseWheelEvents;

	void store(SDL_Event e) nothrow pure @safe {
		//Keyboard
		if (e.type == SDL_KEYDOWN) {
			_pressedKeys ~= Keysym(e.key.keysym.sym, cast(SDL_Keymod) e.key.keysym.mod);
		} else if (e.type == SDL_KEYUP) {
			auto keysym = Keysym(e.key.keysym.sym, cast(SDL_Keymod) e.key.keysym.mod);
			_heldKeys.remove(keysym);
			_releasedKeys ~= keysym;
		}
		//Mouse
		else if (e.type == SDL_MOUSEBUTTONDOWN) {
			static if (sdlSupport == SDLSupport.sdl200) {
				_mouseButtonsPressed ~= MouseButton(e.button.which, e.button.button, 0, Vector2(e.button.x, e.button.y));
			} else {
				_mouseButtonsPressed ~= MouseButton(e.button.which, e.button.button, e.button.clicks, Vector2(e.button.x, e.button.y));
			}
		} else if (e.type == SDL_MOUSEBUTTONUP) {
			static if (sdlSupport == SDLSupport.sdl200) {
				_mouseButtonsReleased ~= MouseButton(e.button.which, e.button.button, 0, Vector2(e.button.x, e.button.y));
			} else {
				_mouseButtonsReleased ~= MouseButton(e.button.which, e.button.button, e.button.clicks, Vector2(e.button.x, e.button.y));
			}
		} else if (e.type == SDL_MOUSEMOTION) {
			_mouseMotionEvents ~= MouseMotion(e.motion.which, e.motion.state, Vector2(e.motion.x, e.motion.y), Vector2(e.motion.xrel, e.motion.yrel));
		} else if (e.type == SDL_MOUSEWHEEL) {
			static if (sdlSupport >= SDLSupport.sdl204) {
				_mouseWheelEvents ~= MouseWheel(e.wheel.which, Vector2(e.wheel.x, e.wheel.y), e.wheel.direction);
			} else {
				_mouseWheelEvents ~= MouseWheel(e.wheel.which, Vector2(e.wheel.x, e.wheel.y));
			}
		}
	}

	void pumpEvents() {
		foreach (key; _pressedKeys) {
			_handler.callEvent(EI_KEY_PRESSED, new KeyboardEventArgs(key));
		}

		foreach (key; _heldKeys.byKey) {
			_handler.callEvent(EI_KEY_HELD, new KeyboardEventArgs(key));
		}

		foreach (key; _releasedKeys) {
			_handler.callEvent(EI_KEY_RELEASED, new KeyboardEventArgs(key));
		}

		foreach (button; _mouseButtonsPressed) {
			_handler.callEvent(EI_MOUSE_PRESSED, new MouseButtonEventArgs(button));
		}

		foreach (button; _mouseButtonsReleased) {
			_handler.callEvent(EI_MOUSE_RELEASED, new MouseButtonEventArgs(button));
		}

		foreach (motion; _mouseMotionEvents) {
			_handler.callEvent(EI_MOUSE_MOVED, new MouseMotionEventArgs(motion));
		}

		foreach (wheel; _mouseWheelEvents) {
			_handler.callEvent(EI_MOUSE_WHEEL, new MouseWheelEventArgs(wheel));
		}
	}

	void nextFrame(int deltaTime) nothrow {
		foreach (key; _pressedKeys) {
			_heldKeys[key] = 0;
		}

		foreach (key; _heldKeys.byKey) {
			_heldKeys[key] += deltaTime;
		}

		_pressedKeys = _pressedKeys.init;
		_releasedKeys = _releasedKeys.init;
	}
}

unittest {
	auto h = new InputHandler();
	auto e = SDL_Event();

	e.key = SDL_KeyboardEvent(
		SDL_KEYDOWN, //Keydown/keyup
		0, 0,        //Timestamp and window information; ignored (perhaps use window info?)
		SDL_PRESSED, //Pressed/released
		0, 0, 0,     //Repeat (first 0) and padding (unused)
		SDL_Keysym(
			SDL_SCANCODE_UNKNOWN, //Scancode not checked
			SDLK_5,  //Virtual key
			0,       //Modifiers
			0        //Unused
		)
	);
	h.store(e);

	auto pressed = Keysym(SDLK_5, KMOD_NONE);
	assert(h._pressedKeys.canFind(pressed));

	e.key = SDL_KeyboardEvent(SDL_KEYUP, 0, 0, SDL_PRESSED, 0, 0, 0, SDL_Keysym(SDL_SCANCODE_UNKNOWN, SDLK_RETURN, KMOD_LCTRL, 0));
	h.store(e);

	auto released = Keysym(SDLK_RETURN, KMOD_LCTRL);
	assert(h._releasedKeys.canFind(released));

	h.nextFrame(50);
	assert(h._heldKeys.byKey.canFind(pressed));
	assert(h._heldKeys[pressed] == 50);
	assert(!h._releasedKeys.canFind(released));
}

/**
 * InputHandler's extensions to standard events.
 */
enum {
	EI_KEY_PRESSED = 0b10000,
	EI_KEY_HELD = 0b10001,
	EI_KEY_RELEASED = 0b10010,
	EI_MOUSE_PRESSED = 0b10011,
	EI_MOUSE_RELEASED = 0b10100,
	EI_MOUSE_MOVED = 0b10101,
	EI_MOUSE_WHEEL = 0b10110
}