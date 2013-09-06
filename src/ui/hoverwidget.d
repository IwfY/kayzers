module ui.hoverwidget;

import utils;
import renderhelper;
import ui.widget;

import derelict.sdl2.sdl;

abstract class HoverWidget : Widget {
	protected string hoverTextureName;
	bool mouseOver;
	
	public this(RenderHelper renderer,
				string name,
				string textureName,
				string hoverTextureName,
				const(SDL_Rect *)bounds) {
		super(renderer, name, textureName, bounds);
		this.hoverTextureName = hoverTextureName;
		this.mouseOver = false;
	}

	public override final void render() {
		if (!this.isHidden()) {
			this.renderer.drawTexture(this.bounds, this.textureName);
			if (mouseOver) {
				this.renderer.drawTexture(this.bounds, this.hoverTextureName);
			}
			this.draw();
		}
	}

	public override void mouseEnter() {
		this.mouseOver = true;
	}

	public override void mouseLeave() {
		this.mouseOver = false;
	}
}
