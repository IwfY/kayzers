module renderer;

import renderhelper;

import derelict.sdl2.sdl;

class Renderer {
	protected RenderHelper renderer;
	protected SDL_Rect *screenRegion;

	public this(RenderHelper renderer) {
		this.renderer = renderer;
		this.screenRegion = new SDL_Rect(0, 0);
	}
	
	public void setScreenRegion(int x, int y, int w, int h) {
		this.screenRegion.x = x;
		this.screenRegion.y = y;
		this.screenRegion.w = w;
		this.screenRegion.h = h;
	}


	/**
	 * abstract methods
	 **/
	public abstract void render();
	public abstract void handleEvent(SDL_Event event);

}
