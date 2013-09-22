module ui.ingamerenderer;

import client;
import ui.renderer;
import ui.renderhelper;
import ui.maprenderer;
import ui.ui;

import derelict.sdl2.sdl;

class InGameRenderer : Renderer {
	private UI ui;
	private MapRenderer mapRenderer;

	public this(Client client, RenderHelper renderer) {
		super(client, renderer);
	}


	public override void render() {

	}


	public override void handleEvent(SDL_Event event) {

	}
}
