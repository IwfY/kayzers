module ui.widget;

import rect;
import utils;
import ui.renderhelper;

import derelict.sdl2.sdl;

abstract class Widget {
	// bounds sets scale for drawing and serves as hit box for interaction
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


	public const(bool) isHidden() const {
		return this.hidden;
	}


	public void render() {
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
		Rect screenRegion = this.renderer.getScreenRegion();
		this.bounds.x = (screenRegion.w - this.bounds.w) / 2;
	}

	public void setBounds(int x, int y, int w, int h) {
		this.bounds.x = x;
		this.bounds.y = y;
		this.bounds.w = w;
		this.bounds.h = h;
	}

	public void setTextureName(string textureName) {
		this.textureName = textureName;
	}
	
	public const(SDL_Rect *)getBounds() const {
		return this.bounds;
	}
	
	public void click() {
	}

	public void mouseEnter() {
	}

	public void mouseLeave() {
	}
}
