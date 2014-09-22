module ui.widgets.image;

import utils;
import ui.renderhelper;
import ui.widgets.widget;

import derelict.sdl2.sdl;

class Image : Widget {
	private string textureName;

	public this(RenderHelper renderer,
				string textureName,
				const(SDL_Rect *)bounds = new SDL_Rect()) {
		super(renderer, bounds);
		this.textureName = textureName;
	}

	public void setTextureName(const(string) textureName) {
		this.textureName = textureName;
	}

	protected override void draw() {
		this.renderer.drawTexture(this.bounds, this.textureName);
	}
}
