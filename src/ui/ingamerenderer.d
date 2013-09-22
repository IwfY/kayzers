module ui.ingamerenderer;

import client;
import messagebroker;
import observer;
import ui.renderer;
import ui.renderhelper;
import ui.maprenderer;
import ui.resourceloader;
import ui.ui;

import derelict.sdl2.sdl;

class InGameRenderer : Renderer, Observer {
	private UI ui;
	private MapRenderer mapRenderer;
	private MessageBroker messageBroker;

	public this(Client client, RenderHelper renderer,
				MessageBroker messageBroker) {
		super(client, renderer);

		this.messageBroker = messageBroker;
		this.messageBroker.register(this, "gameStarted");
		this.messageBroker.register(this, "gameStopped");
	}


	public ~this() {
		this.messageBroker.unregister(this, "gameStarted");
		this.messageBroker.unregister(this, "gameStopped");

		if (this.mapRenderer !is null) {
			delete this.mapRenderer;
		}
		if (this.ui !is null) {
			delete this.ui;
		}
	}


	public override void notify(string message) {
		// a game was started
		if (message == "gameStarted") {
			// load game specific assets
			ResourceLoader.loadGameTextures(this.client, this.renderer);

			// create renderer
			this.mapRenderer = new MapRenderer(
					this.client, this.renderer, this.messageBroker);
			this.ui = new UI(this.client, this.renderer, this.mapRenderer);
		}

		// the game was stopped
		else if (message == "gameStopped") {
			delete this.mapRenderer;
			delete this.ui;
		}
	}


	/**
	 * update the regions the map and ui are supposed to be drawn to
	 **/
	private void updateRendererDrawRegions() {
		this.mapRenderer.setScreenRegion(
				this.screenRegion.x, this.screenRegion.y,
				this.screenRegion.w, this.screenRegion.h - 180);
		this.ui.setScreenRegion(
				this.screenRegion.x, this.screenRegion.h - 180,
				this.screenRegion.w, 180);
	}


	public override void render()
		in {
			assert(this.client.isGameActive(),
				   "InGameRenderer::render no game active");
		}
		body {
			this.updateRendererDrawRegions();
			this.mapRenderer.render();
			this.ui.render();
		}


	public override void handleEvent(SDL_Event event)
		in {
			assert(this.client.isGameActive(),
				   "InGameRenderer::handleEvent no game active");
		}
		body {
			this.mapRenderer.handleEvent(event);
			this.ui.handleEvent(event);
		}
}
