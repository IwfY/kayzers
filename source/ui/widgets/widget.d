module ui.widgets.widget;

import rect;
import utils;
import ui.renderhelper;
import ui.widgets.iwidget;

import derelict.sdl2.sdl;

import std.math;

abstract class Widget : IWidget {
	// bounds sets scale for drawing and serves as hit box for interaction
	protected SDL_Rect *bounds;
	protected RenderHelper renderer;

	// z-index specifies drawing order of overlapping widgets
	// 		higher index widgets are drawn above lower index ones
	protected int zIndex;
	private bool hidden;

	public this(RenderHelper renderer,
				const(SDL_Rect *)bounds = new SDL_Rect()) {
		this.renderer = renderer;
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

	public final const(bool) isPointInBounds(SDL_Point *point) const {
		return rectContainsPoint(this.bounds, point);
	}

	public final const(bool) isPointInBounds(int x, int y) const {
		return rectContainsPoint(this.bounds, x, y);
	}


	public void render() {
		if (!this.hidden) {
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
	public final void hide() {
		this.setHidden(true);
	}
	public final void unhide() {
		this.setHidden(false);
	}
	public void setHidden(const(bool) hidden) {
		this.hidden = hidden;
	}

	public void centerHorizontally(int start, int width) {
		this.setXY(start + cast(int)(floor((width - this.w()) / 2.0)), this.y());
	}

	public void setBounds(int x, int y, int w, int h) {
		this.bounds.x = x;
		this.bounds.y = y;
		this.bounds.w = w;
		this.bounds.h = h;
	}

	public final const(SDL_Rect *) getBounds() const {
		return this.bounds;
	}

	public const(int) x() const {
		return this.bounds.x;
	}
	public const(int) y() const {
		return this.bounds.y;
	}
	public const(int) w() const {
		return this.bounds.w;
	}
	public const(int) h() const {
		return this.bounds.h;
	}

	public void handleEvent(SDL_Event event) {
	}
}
