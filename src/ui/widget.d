module ui.widget;

import utils;
import renderhelper;

import derelict.sdl2.sdl;

abstract class Widget {
	protected SDL_Rect *bounds;
	protected RenderHelper renderer;
	protected string name;
	protected string textureName;
	
	public this(RenderHelper renderer,
				string name,
				string textureName,
				SDL_Rect *bounds) {
		this.renderer = renderer;
		this.name = name;
		this.textureName = textureName;
		this.bounds = bounds;
	}
	
	public bool isPointInBounds(SDL_Point *point) {
		return rectContainsPoint(this.bounds, point);
	}


	public void render() {
		this.renderer.drawTexture(this.bounds.x, this.bounds.y,
									  this.textureName);
	}
	
	abstract public void click();
}
