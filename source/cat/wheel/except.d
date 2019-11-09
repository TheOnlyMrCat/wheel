module cat.wheel.except;

import std.string;
import std.exception;
import bindbc.sdl;

/**
 * Indicates that an error has occurred in an SDL function
 */
class SDLException : Exception {
	package this(string msg) {
		super(msg);
	}
}

/**
 * Checks the return value of an SDL function to be null, and if it is, throws an exception
 * Returns the object
 */
package T objCheck(T)(T obj) {
	if (obj is null) throw new SDLException(SDL_GetError().fromStringz.idup);
	return obj;
}

package void check(int rt) {
	if (rt != 0) throw new SDLException(SDL_GetError().fromStringz.idup);
}
