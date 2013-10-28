module ui.widgets.popupwidgetdecorator;

import constants;
import position;
import ui.label;
import ui.renderhelper;
import ui.widgets.widgetdecorator;
import ui.widgets.widgetinterface;

import derelict.sdl2.sdl;

/**
 * decorator that adds a popup to a widget
 **/
class PopupWidgetDecorator : WidgetDecorator {
	private Label label;

	// interpreted as pixel vector from top-left widget coordinate to
	// bottom-left popup coordinate
	private Position offset;

	public this(WidgetInterface decoratedWidget,
				RenderHelper renderer,
				string labelText,
				string labelBackground,
				Position offset=null,
				string fontName=STD_FONT,
				SDL_Color *color=null) {
		super(decoratedWidget);

		if (offset !is null) {
			this.offset = offset;
		}

		const(SDL_Rect*) widgetBounds = this.decoratedWidget.getBounds();
		SDL_Rect* bounds = new SDL_Rect(
			0, 0,
			0, 0);	// zeroes as Label ignores width and height settings

		this.label = new Label(renderer, "", labelBackground,
							   bounds, labelText, fontName, color);
		this.repositionPopup();
	}


	private void repositionPopup() {
		const(SDL_Rect*) widgetBounds = this.decoratedWidget.getBounds();
		const(SDL_Rect*) popupBounds = this.label.getBounds();

		int x = widgetBounds.x + this.offset.j;
		int y = widgetBounds.y - popupBounds.h + this.offset.j;

		this.label.setXY(x, y);
	}


	public override void centerHorizontally() {
		super.centerHorizontally();
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
		super.render();
		this.label.render();
	}
}
