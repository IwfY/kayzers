module textinput;

import observable;
import renderhelper;
import renderer;
import utils;

import derelict.sdl2.sdl;

import std.stdio;
import std.utf;

class TextInput : Observable {
	private string textInput;
	private bool reading;

	public this() {
		super(1);
		this.reading = false;
	}

	public void start() {
		SDL_StartTextInput();
		this.textInput = "";
		this.reading = true;
	}

	public void stop() {
		this.reading = false;
		SDL_StopTextInput();
		this.notifyObservers();
	}

	public string getTextInput() {
		return this.textInput;
	}

	public bool isReading() {
		return this.reading;
	}

	public void handleEvent(SDL_Event event) {
		if (reading) {	// waiting for TEXTINPUT events
			if (event.type == SDL_TEXTINPUT) {
				char[] text;
				text ~= event.text.text;
				size_t size;
				dchar u = decodeFront!(char[])(text, size);
				this.textInput ~= u;
				this.notifyObservers();
			}
			// key down
			else if (event.type == SDL_KEYDOWN) {
				// input stop
				if (event.key.keysym.sym == SDLK_RETURN) {
					this.stop();
				} else if (event.key.keysym.sym == SDLK_BACKSPACE) {
					dstring tmp = toUTF32(this.textInput);
					if (tmp.length > 0) {
						tmp.length = tmp.length - 1;
						this.textInput = toUTF8(tmp);
						this.notifyObservers();
					}
				}
			}
		}
	}
}
