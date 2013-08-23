module ui.widget;

import utils;
import renderhelper;

import derelict.sdl2.sdl;

abstract class Widget {
	protected SDL_Rect *bounds;
	protected RenderHelper renderer;
	protected string name;
	protected string textureName;
	private bool hidden;
	
	public this(RenderHelper renderer,
				string name,
				string textureName,
				const(SDL_Rect *)bounds) {
		this.renderer = renderer;
		this.name = name;
		this.textureName = textureName;
		this.hidden = false;
		this.bounds = new SDL_Rect(bounds.x, bounds.y, bounds.w, bounds.h);
	}
	
	public bool isPointInBounds(SDL_Point *point) {
		return rectContainsPoint(this.bounds, point);
	}


	public final void render() {
		if (!this.hidden) {
			this.renderer.drawTexture(this.bounds, this.textureName);
			this.draw();
		}
	}

	public abstract void draw();
	
	
	public void setXY(int x, int y) {
		this.bounds.x = x;
		this.bounds.y = y;
	}

	public void hide() {
		this.hidden = true;
	}
	public void unhide() {
		this.hidden = false;
	}
	
	public void centerHorizontally() {
		SDL_Rect *screenRegion = this.renderer.getScreenRegion();
		this.bounds.x = (screenRegion.w - this.bounds.w) / 2;
	}

	public void setBounds(int x, int y, int w, int h) {
		this.bounds.x = x;
		this.bounds.y = y;
		this.bounds.w = w;
		this.bounds.h = h;
	}
	
	public const(SDL_Rect *)getBounds() const {
		return this.bounds;
	}
	
	abstract public void click();
}
