module ui.widgets.hoverwidget;

import utils;
import ui.renderhelper;
import ui.widgets.widget;

import derelict.sdl2.sdl;

abstract class HoverWidget : Widget {
	protected string textureName;
	protected string hoverTextureName;
	protected bool mouseOver;

	public this(RenderHelper renderer,
				string textureName,
				string hoverTextureName,
				const(SDL_Rect *)bounds = new SDL_Rect()) {
		super(renderer, bounds);
		this.textureName = textureName;
		this.hoverTextureName = hoverTextureName;
		this.mouseOver = false;
	}

	public override void draw() {
		this.renderer.drawTexture(this.bounds, this.textureName);
		if (this.mouseOver) {
			this.renderer.drawTexture(this.bounds, this.hoverTextureName);
		}
	}

	public void setTextureName(string textureName) {
		this.textureName = textureName;
	}

	public void setHoverTextureName(string hoverTextureName) {
		this.hoverTextureName = hoverTextureName;
	}
	
	public override void handleEvent(SDL_Event event) {
		if (this.isHidden()) {
			return;
		}
		
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
