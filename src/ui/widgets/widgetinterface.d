module ui.widgets.widgetinterface;

import derelict.sdl2.sdl;

interface WidgetInterface {
	public const(int) getZIndex() const;
	public void setZIndex(int zIndex);
	public bool isPointInBounds(SDL_Point *point);
	public void centerHorizontally();
	public void setBounds(int x, int y, int w, int h);
	public const(SDL_Rect *) getBounds() const;
	public void setXY(int x, int y);

	public const(bool) isHidden() const;
	public void hide();
	public void unhide();

	public void render();
	protected void draw();

	public void setTextureName(string textureName);
	public const(string) getName() const;

	public void click();
	public void mouseEnter();
	public void mouseLeave();

	static bool zIndexSort(WidgetInterface a, WidgetInterface b) {
		return (a.getZIndex() < b.getZIndex());
	}
}
