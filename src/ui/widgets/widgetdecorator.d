module ui.widgets.widgetdecorator;

import ui.widgets.widgetinterface;

import derelict.sdl2.sdl;

abstract class WidgetDecorator : WidgetInterface {
	protected WidgetInterface decoratedWidget;

	public this(WidgetInterface decoratedWidget) {
		this.decoratedWidget = decoratedWidget;
	}

	public const(int) getZIndex() const {
		return this.decoratedWidget.getZIndex();
	}
	public void setZIndex(int zIndex) {
		this.decoratedWidget.setZIndex(zIndex);
	}

	public bool isPointInBounds(SDL_Point *point) {
		return this.decoratedWidget.isPointInBounds(point);
	}

	public void render() {
		this.draw();
	}

	protected override void draw() {
		this.decoratedWidget.render();
	}

	public void setXY(int x, int y) {
		this.decoratedWidget.setXY(x, y);
	}

	public const(bool) isHidden() const {
		return this.decoratedWidget.isHidden();
	}
	public void hide() {
		this.decoratedWidget.hide();
	}
	public void unhide() {
		this.decoratedWidget.unhide();
	}

	public void centerHorizontally() {
		this.decoratedWidget.centerHorizontally();
	}

	public void setBounds(int x, int y, int w, int h) {
		this.decoratedWidget.setBounds(x, y, w, h);
	}
	public const(SDL_Rect *) getBounds() const {
		return this.decoratedWidget.getBounds();
	}

	public void click() {
		this.decoratedWidget.click();
	}

	public void mouseEnter() {
		this.decoratedWidget.mouseEnter();
	}

	public void mouseLeave() {
		this.decoratedWidget.mouseLeave();
	}

	public void setTextureName(string textureName) {
		this.decoratedWidget.setTextureName(textureName);
	}
	public const(string) getName() const {
		return this.decoratedWidget.getName();
	}
}
