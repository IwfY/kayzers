module ui.widgets.line;

import color;
import constants;
import ui.renderhelper;
import ui.widgets.widget;

import derelict.sdl2.sdl;

class Line : Widget {
	private Color color;

	public this(RenderHelper renderer,
				const(SDL_Rect *)bounds = new SDL_Rect(),
				Color color=new Color(255, 255, 255)) {
		super(renderer, bounds);
		this.color = color;
	}

	protected override void draw() {
		this.renderer.drawLine(
				this.x(),
				this.y(),
				this.x() + this.w(),
				this.y() + this.h(),
				this.color);
	}
}
