module ui.widgets.widgetdecorator;

import ui.widgets.iwidget;

import derelict.sdl2.sdl;

abstract class WidgetDecorator : IWidget {
	protected IWidget decoratedWidget;

	public this(IWidget decoratedWidget) {
		this.decoratedWidget = decoratedWidget;
	}

	public const(int) getZIndex() const {
		return this.decoratedWidget.getZIndex();
	}
	public void setZIndex(int zIndex) {
		this.decoratedWidget.setZIndex(zIndex);
	}

	public const(bool) isPointInBounds(SDL_Point *point) const {
		return this.decoratedWidget.isPointInBounds(point);
	}

	public const(bool) isPointInBounds(int x, int y) const {
		return this.decoratedWidget.isPointInBounds(x, y);
	}

	public void setXY(int x, int y) {
		this.decoratedWidget.setXY(x, y);
	}
	public void setBounds(int x, int y, int w, int h) {
		this.decoratedWidget.setBounds(x, y, w, h);
	}
	public void centerHorizontally(int start, int width) {
		this.decoratedWidget.centerHorizontally(start, width);
	}

	public const(SDL_Rect *) getBounds() const {
		return this.decoratedWidget.getBounds();
	}
	public const(int) x() const {
		return this.decoratedWidget.x();
	}
	public const(int) y() const {
		return this.decoratedWidget.y();
	}
	public const(int) w() const {
		return this.decoratedWidget.w();
	}
	public const(int) h() const {
		return this.decoratedWidget.h();
	}

	public const(bool) isHidden() const {
		return this.decoratedWidget.isHidden();
	}
	public void setHidden(const(bool) hidden) {
		this.decoratedWidget.setHidden(hidden);
	}
	public final void hide() {
		this.setHidden(true);
	}
	public final void unhide() {
		this.setHidden(false);
	}

	public final void render() {
		if (!this.isHidden()) {
			this.draw();
		}
	}
	protected void draw() {
		this.decoratedWidget.render();
	}

	public void handleEvent(SDL_Event event) {
		this.decoratedWidget.handleEvent(event);
	}
}
