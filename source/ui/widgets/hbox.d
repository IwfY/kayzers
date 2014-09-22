module ui.widgets.hbox;

import utils;
import ui.renderhelper;
import ui.widgets.containerwidget;
import ui.widgets.iwidget;

import derelict.sdl2.sdl;

/**
 * widget container that arranges its children horizontally
 **/
class HBox : ContainerWidget {
	private int margin;	// horizontal gap between child widgets

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
		this.dirty = true;
	}

	protected override void updateChildren() {
		int x = 0;
		int maxHeight = 0;
		foreach (IWidget widget; this.children) {
			widget.setXY(this.x() + x, this.y());
			x += widget.w() + this.margin;
			maxHeight = max(cast(const(int))maxHeight, widget.h());
		}
		this.bounds.h = maxHeight;
		// prevent negative width for empty box
		this.bounds.w = max(0, x - this.margin);
	}
}

