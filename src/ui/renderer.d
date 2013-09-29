module ui.renderer;

import client;
import rect;
import ui.renderhelper;

import derelict.sdl2.sdl;

class Renderer {
	protected Client client;
	protected RenderHelper renderer;
	protected Rect screenRegion;

	public this(Client client, RenderHelper renderer) {
		this.client = client;
		this.renderer = renderer;
		this.screenRegion = new Rect();
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
	public abstract void render(int tick=0);
	public abstract void handleEvent(SDL_Event event);

}
