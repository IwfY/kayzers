module ui.widget;

import utils;
import renderer;

import derelict.sdl2.sdl;

class Widget {
	protected SDL_Rect *bounds;
	protected Renderer renderer;
	protected string name;
	protected string textureName;
	
	public this(Renderer renderer,
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
}
