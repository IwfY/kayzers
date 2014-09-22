module ui.widgets.popupwidgetdecorator;

import constants;
import position;
import ui.renderhelper;
import ui.widgets.iwidget;
import ui.widgets.label;
import ui.widgets.widgetdecorator;

import derelict.sdl2.sdl;

import std.string;

/**
 * decorator that adds a popup to a widget
 **/
class PopupWidgetDecorator : WidgetDecorator {
	private Label label;
	protected bool mouseOver;

	// interpreted as pixel vector from top-left widget coordinate to
	// bottom-left popup coordinate
	private Position offset;

	public this(IWidget decoratedWidget,
				RenderHelper renderer,
				string labelText,
				string labelBackground,
				Position offset=null,
				string fontName=STD_FONT,
				SDL_Color *color=null) {
		super(decoratedWidget);

		if (offset !is null) {
			this.offset = offset;
		} else {
			this.offset = new Position(5, -5);
		}

		// create popup label
		const(SDL_Rect*) widgetBounds = this.decoratedWidget.getBounds();
		SDL_Rect* bounds = new SDL_Rect(
			0, 0,
			0, 0);	// zeroes as Label ignores width and height settings

		this.label = new Label(
			renderer, labelText, fontName, color, labelBackground);
		this.label.setPadding(5, 3);

		this.repositionPopup();

		this.mouseOver = false;
	}


	private void repositionPopup() {
		const(SDL_Rect*) widgetBounds = this.decoratedWidget.getBounds();
		const(SDL_Rect*) popupBounds = this.label.getBounds();

		int x = widgetBounds.x + this.offset.i;
		int y = widgetBounds.y - popupBounds.h + this.offset.j;

		this.label.setXY(x, y);
	}


	public override void centerHorizontally(int start, int width) {
		super.centerHorizontally(start, width);
		this.repositionPopup();
	}

	public override void setBounds(int x, int y, int w, int h) {
		super.setBounds(x, y, w, h);
		this.repositionPopup();
	}

	public override void setXY(int x, int y) {
		super.setXY(x, y);
		this.repositionPopup();
	}

	protected override void draw() {
		if (this.isHidden()) {
			return;
		}

		super.draw();
		if (this.mouseOver) {
			this.label.render();
		}
	}

	public override void handleEvent(SDL_Event event) {
		if (this.isHidden()) {
			return;
		}

		super.handleEvent(event);

		// mouse motion --> hover effects
		if (event.type == SDL_MOUSEMOTION) {
			if (this.isPointInBounds(event.motion.x, event.motion.y)) {
				if (!this.mouseOver) {
					this.mouseOver = true;
				}
			} else {
				if (this.mouseOver) {
					this.mouseOver = false;
				}
			}
		}
	}
}
