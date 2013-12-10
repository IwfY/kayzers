module ui.widgets.iwidget;

import derelict.sdl2.sdl;

interface IWidget {
	public const(int) getZIndex() const;
	public void setZIndex(int zIndex);

	public const(bool) isPointInBounds(SDL_Point *point) const;
	public const(bool) isPointInBounds(int x, int y) const;

	public void setXY(int x, int y);
	public void setBounds(int x, int y, int w, int h);
	public void centerHorizontally(int start, int width);

	public const(SDL_Rect *) getBounds() const;
	public const(int) x() const;
	public const(int) y() const;
	public const(int) w() const;
	public const(int) h() const;

	public const(bool) isHidden() const;
	public void setHidden(const(bool) hidden);
	public void hide();
	public void unhide();

	public void render();
	protected void draw();

	public void handleEvent(SDL_Event event);

	static bool zIndexSort(IWidget a, IWidget b) {
		return (a.getZIndex() < b.getZIndex());
	}

	static bool zIndexSortDesc(IWidget a, IWidget b) {
		return (a.getZIndex() > b.getZIndex());
	}
}

