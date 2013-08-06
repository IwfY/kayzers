module inputbox;

import renderhelper;
import renderer;
import utils;

import derelict.sdl2.sdl;

import std.stdio;
import std.utf;

class InputBox : Renderer {
	private SDL_Rect *inputRect;
	private string textInput;
	private bool reading;

	public this(RenderHelper renderer) {
		super(renderer);

		this.inputRect = new SDL_Rect(0, 0, 200, 50);
		this.reading = false;
	}

	public override void render() {
		this.renderer.drawText(0, 0, this.textInput);
	}

	public override void handleEvent(SDL_Event event) {
		if (reading) {	// waiting for TEXTINPUT events
			if (event.type == SDL_TEXTINPUT) {
				writeln("textinputevent");
				char[] text;
				text ~= event.text.text;
				size_t size;
				dchar u = decodeFront!(char[])(text, size);
				this.textInput ~= u;
			}
			// key down
			else if (event.type == SDL_KEYDOWN) {
				// input stop
				if (event.key.keysym.sym == SDLK_RETURN) {
					SDL_StopTextInput();
					this.reading = false;
				}
			}
		} else {
			// left mouse down
			if (event.type == SDL_MOUSEBUTTONDOWN &&
					event.button.button == SDL_BUTTON_LEFT) {
				SDL_Point *mousePosition =
						new SDL_Point(event.button.x, event.button.y);

				if (rectContainsPoint(this.inputRect, mousePosition)) {
					SDL_SetTextInputRect(this.inputRect);
					SDL_StartTextInput();
					this.textInput = "";
					this.reading = true;
				}
			}
		}
	}
}
