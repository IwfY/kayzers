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
	private IWidget[] children;
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
		int x = this.x();
		int maxHeight = 0;
		foreach (IWidget widget; this.children) {
			widget.setXY(x, this.y());
			x += widget.w() + this.margin;
			maxHeight = max(cast(const(int))maxHeight, widget.h());
		}
		this.bounds.h = maxHeight;
		this.bounds.w = x;
	}
}

