module ui.inputbox;

import observer;
import rect;
import renderhelper;
import textinput;
import utils;
import ui.widget;

import derelict.sdl2.sdl;


class InputBox : Widget, Observer {
	private string *text;
	private string fontName;
	private SDL_Color *color;
	private TextInput textInputServer;

	public this(RenderHelper renderer,
				string name,
				string textureName,
				SDL_Rect *bounds,
				string fontName,
				SDL_Color *color = null) {
		super(renderer, name, textureName, bounds);
		this.fontName = fontName;
		if (color is null) {
			this.color = new SDL_Color(255, 255, 255);
		} else {
			this.color = color;
		}

		this.textInputServer = this.renderer.getTextInputServer();
	}


	public void setTextPointer(string *text) {
		this.text = text;
	}


	private Rect getTextSize()
		in {
			assert(this.text !is null);
		}
		body {
			return this.renderer.getTextSize(*(this.text), this.fontName);
		}


	public override void click() {
		if (this.text is null) {
			return;
		}

		if (this.textInputServer.registerObserver(this)) {
			this.textInputServer.start();
		}
	}

	public override void notify() {
		if (this.text is null) {
			return;
		}

		// get updated text
		*(this.text) = this.textInputServer.getTextInput();
		// if input server stopped reading we unregister
		if (!this.textInputServer.isReading()) {
			this.textInputServer.unregisterObserver(this);
		}
	}

	public override void draw() {
		if (this.text is null) {
			return;
		}

		int boundsY = this.bounds.y +
				(this.bounds.h - this.getTextSize().h) / 2;
		string printText = *(this.text);
		this.renderer.drawText(this.bounds.x + 5, boundsY,
							   printText,
							   this.fontName, this.color);
	}
}
