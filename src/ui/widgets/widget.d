module ui.widgets.widget;

import rect;
import utils;
import ui.renderhelper;
import ui.widgets.widgetinterface;

import derelict.sdl2.sdl;

abstract class Widget : WidgetInterface {
	// bounds sets scale for drawing and serves as hit box for interaction
	protected SDL_Rect *bounds;
	protected RenderHelper renderer;
	protected string name;
	protected string textureName;

	// z-index specifies drawing order of overlapping widgets
	// 		higher index widgets are drawn above lower index ones
	protected int zIndex;
	private bool hidden;

	public this(RenderHelper renderer,
				string name,
				string textureName,
				const(SDL_Rect *)bounds = new SDL_Rect()) {
		this.renderer = renderer;
		this.name = name;
		this.textureName = textureName;
		this.hidden = false;
		this.bounds = new SDL_Rect(bounds.x, bounds.y, bounds.w, bounds.h);
		this.zIndex = 0;
	}


	public final const(int) getZIndex() const {
		return this.zIndex;
	}

	public void setZIndex(int zIndex) {
		this.zIndex = zIndex;
	}

	public final bool isPointInBounds(SDL_Point *point) {
		return rectContainsPoint(this.bounds, point);
	}


	public void render() {
		if (!this.hidden) {
			this.renderer.drawTexture(this.bounds, this.textureName);
			this.draw();
		}
	}

	protected abstract void draw();


	public void setXY(int x, int y) {
		this.bounds.x = x;
		this.bounds.y = y;
	}

	public final const(bool) isHidden() const {
		return this.hidden;
	}
	public void hide() {
		this.hidden = true;
	}
	public void unhide() {
		this.hidden = false;
	}

	public void centerHorizontally() {
		Rect screenRegion = this.renderer.getScreenRegion();
		this.setXY((screenRegion.w - this.bounds.w) / 2,
			this.bounds.y);
	}

	public void setBounds(int x, int y, int w, int h) {
		this.bounds.x = x;
		this.bounds.y = y;
		this.bounds.w = w;
		this.bounds.h = h;
	}

	public final void setTextureName(string textureName) {
		this.textureName = textureName;
	}

	public final const(SDL_Rect *) getBounds() const {
		return this.bounds;
	}

	public final const(string) getName() const {
		return this.name;
	}

	public void setText(string text) {
	}

	public void click() {
	}

	public void mouseEnter() {
	}

	public void mouseLeave() {
	}

	static bool zIndexSort(Widget a, Widget b) {
		return (a.getZIndex() < b.getZIndex());
	}
}
