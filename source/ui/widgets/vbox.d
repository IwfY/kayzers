module ui.widgets.vbox;

import utils;
import ui.renderhelper;
import ui.widgets.containerwidget;
import ui.widgets.iwidget;

import derelict.sdl2.sdl;

/**
 * widget container that arranges its children vertically
 **/
class VBox : ContainerWidget {
	private int margin;	// vertical gap between child widgets

	public this(RenderHelper renderer,
	            const(SDL_Rect *)bounds = new SDL_Rect()) {
		super(renderer, bounds);
		this.margin = 5;
	}


	public const(int) getMargin() const {
		return this.margin;
	}
	public void setMargin(int margin) {
		this.margin = margin;
		this.updateChildren();
	}

	protected override void updateChildren() {
		int y = 0;
		int maxWidth = 0;
		foreach (IWidget widget; this.children) {
			widget.setXY(this.x(), this.y() + y);
			y += widget.h() + this.margin;
			maxWidth = max(cast(const(int))maxWidth, widget.w());
		}
		// prevent negative height for empty box
		this.bounds.h = max(0, y - this.margin);
		this.bounds.w = maxWidth;
	}
}

