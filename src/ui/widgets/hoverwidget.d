module ui.hoverwidget;

import utils;
import ui.renderhelper;
import ui.widgets.widget;

import derelict.sdl2.sdl;

abstract class HoverWidget : Widget {
	protected string textureName;
	protected string hoverTextureName;
	bool mouseOver;

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

	public void setHoverTextureName(string hoverTextureName) {
		this.hoverTextureName = hoverTextureName;
	}
	
	public override void handleEvent(SDL_Event event) {
		if (this.isHidden()) {
			return;
		}
		
		// mouse motion --> hover effects
		if (event.type == SDL_MOUSEMOTION) {
			SDL_Point *mousePosition =
					new SDL_Point(event.button.x, event.button.y);
			if (this.isPointInBounds(mousePosition)) {
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
