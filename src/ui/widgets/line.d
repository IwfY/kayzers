module ui.widgets.line;

import color;
import constants;
import ui.renderhelper;
import ui.widgets.widget;

import derelict.sdl2.sdl;

class Line : Widget {
	private Color color;

	public this(RenderHelper renderer,
				string name,
				const(SDL_Rect *)bounds,
				Color color=new Color(255, 255, 255)) {
		super(renderer, name, NULL_TEXTURE, bounds);
		this.color = color;
	}

	protected override void draw() {
		this.renderer.drawLine(
				this.bounds.x,
				this.bounds.y,
				this.bounds.x + this.bounds.w,
				this.bounds.y + this.bounds.h,
				this.color);
	}
}
