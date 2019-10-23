module cat.wheel.input;

import std.algorithm.searching;
import core.vararg;
import derelict.sdl2.sdl;

import cat.wheel.events;
import cat.wheel.keysym;

/**
 * An input handler, which keeps track of what inputs are being held, pressed, released, etc.
 */
class InputHandler {

	/// Exists for unit testing purposes
	private this() {}

	/**
	 * Constructs an input handler from an SDL handler, which it attaches delegates to.
	 */
	this(Handler h) {
		_handler = h;

		_handler.addDelegate((...) => nextFrame(_handler.time), ED_PRE_PUMP);

		_handler.addDelegate((...) {
			if (_arguments[0] == typeid(SDL_Event)) store(va_arg!SDL_Event(_argptr));
		}, ED_PUMP);

		_handler.addDelegate((...) => pumpEvents(), ED_PRE_TICK);
	}

private:
	Handler _handler;

	Keysym[] _pressedKeys;
	int[Keysym] _heldKeys;
	Keysym[] _releasedKeys;

	void store(SDL_Event e) nothrow {
		if (e.type == SDL_KEYDOWN) {
			_pressedKeys ~= Keysym(cast(KeyCode) e.key.keysym.sym, cast(KeyMod) e.key.keysym.mod);
		} else if (e.type == SDL_KEYUP) {
			auto keysym = Keysym(cast(KeyCode) e.key.keysym.sym, cast(KeyMod) e.key.keysym.mod);
			_heldKeys.remove(keysym);
			_releasedKeys ~= keysym;
		}
	}

	void pumpEvents() {
		foreach (key; _pressedKeys) {
			_handler.callEvent(EI_KEY_PRESSED, key);
		}

		foreach (key; _heldKeys.byKey) {
			_handler.callEvent(EI_KEY_HELD, key, _heldKeys[key]);
		}

		foreach (key; _releasedKeys) {
			_handler.callEvent(EI_KEY_RELEASED, key);
		}
	}

	void nextFrame(int deltaTime) {
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
			0,       //Scancode not checked
			SDLK_5,  //Virtual key
			0,       //Modifiers
			0        //Unused
		)
	);

	h.store(e);
	assert(h._pressedKeys.canFind(Keysym(KeyCode.N5, KeyMod.NONE)));

	e.key = SDL_KeyboardEvent(SDL_KEYUP, 0, 0, SDL_PRESSED, 0, 0, 0, SDL_Keysym(0, SDLK_RETURN, KMOD_LCTRL, 0));
	h.store(e);
	assert(h._releasedKeys.canFind(Keysym(KeyCode.RETURN, KeyMod.LCTRL)));
}

/**
 * InputHandler's extensions to standard events.
 */
enum {
	EI_KEY_PRESSED = 0b10000,
	EI_KEY_HELD = 0b10001,
	EI_KEY_RELEASED = 0b10010,
}