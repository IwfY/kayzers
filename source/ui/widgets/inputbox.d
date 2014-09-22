module ui.widgets.inputbox;

import message;
import observer;
import rect;
import textinput;
import utils;
import ui.renderhelper;
import ui.widgets.widget;

import derelict.sdl2.sdl;

import std.datetime;


class InputBox : Widget, Observer {
	private string *text;
	private string fontName;
	private string textureName;
	private SDL_Color *color;
	private TextInput textInputServer;
	private bool inputServerRegistered;

	public this(RenderHelper renderer,
				TextInput textInputServer,
				string textureName,
				SDL_Rect *bounds,
				string fontName,
				SDL_Color *color = null) {
		super(renderer, bounds);
		this.textureName = textureName;
		this.fontName = fontName;
		if (color is null) {
			this.color = new SDL_Color(255, 255, 255);
		} else {
			this.color = color;
		}

		this.textInputServer = textInputServer;
		this.inputServerRegistered = false;
	}


	public void setTextPointer(string *text) {
		this.text = text;
		this.textInputServer.setText(*text);
	}


	private Rect getTextSize()
		in {
			assert(this.text !is null);
		}
		body {
			return this.renderer.getTextSize(*(this.text), this.fontName);
		}


	public override void notify(const(Message) message) {
		if (this.text is null) {
			return;
		}

		// get updated text
		*(this.text) = this.textInputServer.getTextInput();
		// if input server stopped reading we unregister
		if (!this.textInputServer.isReading()) {
			this.textInputServer.unregisterObserver(this);
			this.inputServerRegistered = false;
		}
	}

	protected override void draw() {
		this.renderer.drawTexture(this.bounds, this.textureName);

		if (this.text is null) {
			return;
		}

		int boundsY = this.y() + (this.h() - this.getTextSize().h) / 2;
		string printText = *(this.text);
		if (this.textInputServer.isReading()) {
			SysTime time = Clock.currTime();
			if (time.fracSec.msecs < 500) {
				printText ~= "|";
			}
		}
		this.renderer.drawText(this.x() + 5, boundsY,
							   printText,
							   this.fontName, this.color);
	}


	public void click() {
		if (this.text is null) {
			return;
		}

		if (this.textInputServer.registerObserver(this) &&
				!this.inputServerRegistered) {
			this.textInputServer.start();
			this.inputServerRegistered = true;
		}
	}

	public override void handleEvent(SDL_Event event) {
		if (this.isHidden()) {
			return;
		}

		super.handleEvent(event);

		// left mouse down
		if (event.type == SDL_MOUSEBUTTONDOWN &&
				event.button.button == SDL_BUTTON_LEFT) {
			SDL_Point *mousePosition =
					new SDL_Point(event.button.x, event.button.y);
			if (this.isPointInBounds(mousePosition)) {
				this.click();
			}
		}
	}
}
