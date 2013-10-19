module ui.ingamerenderer;

import client;
import messagebroker;
import observer;
import ui.renderer;
import ui.renderhelper;
import ui.maprenderer;
import ui.resourceloader;
import ui.structurenamerenderer;
import ui.ui;
import world.structure;

import derelict.sdl2.sdl;

class InGameRenderer : Renderer, Observer {
	private UI ui;
	private MapRenderer mapRenderer;
	private StructureNameRenderer structureNameRenderer;

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


	public void startStructureNameRenderer(const(Structure) structure) {
		this.structureNameRenderer = new StructureNameRenderer(
			this.client, this.renderer, structure);
	}


	public override void notify(string message) {
		// a game was started
		if (message == "gameStarted") {
			// load game specific assets
			ResourceLoader.loadGameTextures(this.client, this.renderer);

			// create renderer
			this.mapRenderer = new MapRenderer(
				this.client, this.renderer, this.messageBroker);
			this.ui = new UI(
				this.client, this.renderer, this, this.mapRenderer);
			this.updateRendererDrawRegions();
		}

		// the game was stopped
		else if (message == "gameStopped") {
			delete this.mapRenderer;
			delete this.ui;

			// structure naming
			if (this.structureNameRenderer !is null) {
				delete this.structureNameRenderer;
			}
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

		if (this.structureNameRenderer !is null) {
			this.structureNameRenderer.setScreenRegion(
				this.screenRegion.x, this.screenRegion.y,
				this.screenRegion.w, this.screenRegion.h);
		}
	}


	public override void render(int tick=0)
		in {
			assert(this.client.isGameActive(),
				   "InGameRenderer::render no game active");
		}
		body {
			this.updateRendererDrawRegions();
			this.mapRenderer.render(tick);
			this.ui.render(tick);

			// structure naming
			if (this.structureNameRenderer !is null) {
				this.structureNameRenderer.render(tick);
			}
		}


	public override void handleEvent(SDL_Event event)
		in {
			assert(this.client.isGameActive(),
				   "InGameRenderer::handleEvent no game active");
		}
		body {
			// structure naming
			if (this.structureNameRenderer !is null) {
				this.structureNameRenderer.handleEvent(event);
				// if event triggered deactivation of text input renderer - delete it
				if (!this.structureNameRenderer.isActive()) {
					delete this.structureNameRenderer;
				}
				return;
			}

			this.mapRenderer.handleEvent(event);
			this.ui.handleEvent(event);
		}
}
