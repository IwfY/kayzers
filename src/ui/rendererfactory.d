module ui.rendererfactory;

import client;
import ui.renderer;
import ui.renderhelper;
import ui.resourceloader;
import ui.renderdispatcher;

import derelict.sdl2.sdl;

class RendererFactory {
	/**
	 * create the rendering infrastructure and return the root renderer
	 **/
	public static Renderer makeRenderInfrastructure(
			Client client, SDL_Window *window) {
		RenderHelper renderHelper = new RenderHelper(window);

		ResourceLoader.loadTexturesAndFonts(renderHelper);

		RenderDispatcher root = new RenderDispatcher(client, renderHelper);

		return root;
	}

}
