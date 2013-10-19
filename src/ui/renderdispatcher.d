module ui.renderdispatcher;

import client;
import messagebroker;
import rect;
import ui.ingamerenderer;
import ui.mainmenu;
import ui.renderer;
import ui.renderhelper;
import ui.renderstate;

import derelict.sdl2.sdl;

class RenderDispatcher : Renderer {
	// Renderer
	private MainMenu mainMenu;
	private InGameRenderer inGameRenderer;
	private RenderState renderState;


	public this(Client client, RenderHelper renderer,
				MessageBroker messageBroker) {
		super(client, renderer);

		this.renderState = new RenderState();

		this.mainMenu = new MainMenu(
				this.client, this.renderer, this.renderState);

		this.inGameRenderer = new InGameRenderer(
				this.client, this.renderer, messageBroker);
	}


	public ~this() {
		destroy(this.mainMenu);
		destroy(this.inGameRenderer);

		destroy(this.renderer);
	}


	/**
	 * update the regions each renderer may draw to
	 **/
	private void updateRendererDrawRegions() {
		Rect screen = this.renderer.getScreenRegion();

		this.mainMenu.setScreenRegion(0, 0, screen.w, screen.h);
		this.inGameRenderer.setScreenRegion(0, 0, screen.w, screen.h);
	}


	public override void render(int tick=0) {
		this.updateRendererDrawRegions();
		this.renderer.setDrawColor(0, 0, 0, 255);	// set black
		this.renderer.clear();

		if (this.renderState.getState() == Modus.MAIN_MENU) {
			this.mainMenu.render(tick);
		} else if (this.renderState.getState() == Modus.IN_GAME) {
			this.inGameRenderer.render(tick);
		}

		this.renderer.renderPresent();
	}


	public override void handleEvent(SDL_Event event) {
		if (this.renderState.getState() == Modus.MAIN_MENU) {
			this.mainMenu.handleEvent(event);
		} else if (this.renderState.getState() == Modus.IN_GAME) {
			this.inGameRenderer.handleEvent(event);
		}
	}
}
