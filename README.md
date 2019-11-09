# Wheel

[![Build Status](https://img.shields.io/travis/TheOnlyMrCat/wheel?style=flat-square)](https://travis-ci.org/TheOnlyMrCat/wheel)
[![Dub package](https://img.shields.io/dub/v/wheel?style=flat-square)](http://wheel.dub.pm/)
[![License](https://img.shields.io/github/license/TheOnlyMrCat/wheel?style=flat-square)](https://github.com/TheOnlyMrCat/wheel/blob/master/LICENSE)

Wheel is a library for the [D programming language](https://www.dlang.org) which provides
a high-level interface to the [Simple DirectMedia Layer (SDL)](https://www.libsdl.org) library.

It is built upon the [BindBC SDL binding](https://code.dlang.org/packages/bindbc-sdl) and some
imports are required from BindBC to set SDL up and use some features.

## Using Wheel

To start using wheel, follow the instructions to set up the [SDL binding](https://code.dlang.org/packages/bindbc-sdl).
To initialize SDL, call the `initSDL` and `initSystem` functions in `cat.wheel.events` as
necessary to set up the required subsystems. The functions essentially map `SDL_Init` and
`SDL_InitSubSystem` with exception checking. To quit SDL, call `quitSDL` or `quitSystem`.

The main "selling point" of wheel is the `Handler` class. A `Handler` instance has a method
`handle` which starts a loop of SDL event polling and function calling. Functions get
registered as delegates to the `Handler` instance, and called when predetermined events get
fired by the handler.

A typical simple program would look like this (barring the BindBC code):

```d
import cat.wheel.events;

void main() {
    initSDL();

    auto h = new Handler();

    h.addDelegate((args) {
        if ((cast(PumpEventArgs) args).event.type == SDL_EventType.SDL_QUIT) {
            h.stop();
        }
    }, ED_PUMP);

    h.handle();

    quitSDL();
}
```
