module ui.ingamerenderer;

import client;
import message;
import messagebroker;
import observer;
import ui.characternamerenderer;
import ui.renderer;
import ui.renderhelper;
import ui.maprenderer;
import ui.notificationrenderer;
import ui.resourceloader;
import ui.structurenamerenderer;
import ui.ui;
import world.character;
import world.structure;

import derelict.sdl2.sdl;

class InGameRenderer : Renderer, Observer {
	private UI ui;
	private MapRenderer mapRenderer;
	private StructureNameRenderer structureNameRenderer;
	private CharacterNameRenderer characterNameRenderer;
	private NotificationRenderer notificationRenderer;

	private MessageBroker messageBroker;


	public this(Client client, RenderHelper renderer,
				MessageBroker messageBroker) {
		super(client, renderer);

		this.messageBroker = messageBroker;
		this.messageBroker.register(this, "gameStarted");
		this.messageBroker.register(this, "gameStopped");
		this.messageBroker.register(this, "nameCharacter");
	}


	public ~this() {
		this.messageBroker.unregister(this, "gameStarted");
		this.messageBroker.unregister(this, "gameStopped");
		this.messageBroker.unregister(this, "nameCharacter");

		this.destroyChildRenderer();
	}


	private void destroyChildRenderer() {
		if (this.mapRenderer !is null) {
			destroy(this.mapRenderer);
		}
		if (this.ui !is null) {
			destroy(this.ui);
		}
		if (this.notificationRenderer !is null) {
			destroy(this.notificationRenderer);
		}

		// structure naming
		if (this.structureNameRenderer !is null) {
			destroy(this.structureNameRenderer);
		}

		if (this.characterNameRenderer !is null) {
			destroy(this.characterNameRenderer);
		}
	}


	public void startStructureNameRenderer(const(Structure) structure) {
		this.structureNameRenderer = new StructureNameRenderer(
			this.client, this.renderer, structure);
	}

	public void startCharacterNameRenderer(const(Character) character) {
		this.characterNameRenderer = new CharacterNameRenderer(
			this.client, this.renderer, character);
	}


	public override void notify(const(Message) message) {
		// a game was started
		if (message.text == "gameStarted") {
			// load game specific assets
			ResourceLoader.loadGameTextures(this.client, this.renderer);

			// create renderer
			this.mapRenderer = new MapRenderer(
				this.client, this.renderer, this.messageBroker);
			this.ui = new UI(
				this.client, this.renderer, this, this.mapRenderer, this.messageBroker);
			this.notificationRenderer = new NotificationRenderer(
				this.client, this.renderer, this.messageBroker);
			this.updateRendererDrawRegions();
		}

		// the game was stopped
		else if (message.text == "gameStopped") {
			this.destroyChildRenderer();
		}

		// new character to be named
		else if (message.text == "nameCharacter") {
			assert(typeid(message) == typeid(ObjectMessage!(const(Character))));
			ObjectMessage!(const(Character)) objectMessage =
				cast(ObjectMessage!(const(Character)))message;
			const(Character) character = objectMessage.object;
			this.startCharacterNameRenderer(character);
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
		this.notificationRenderer.setScreenRegion(
				this.screenRegion.x, this.screenRegion.y,
				this.screenRegion.w, this.screenRegion.h);

		if (this.structureNameRenderer !is null) {
			this.structureNameRenderer.setScreenRegion(
				this.screenRegion.x, this.screenRegion.y,
				this.screenRegion.w, this.screenRegion.h);
		}

		if (this.characterNameRenderer !is null) {
			this.characterNameRenderer.setScreenRegion(
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
			this.notificationRenderer.render(tick);

			// structure naming
			if (this.structureNameRenderer !is null) {
				this.structureNameRenderer.render(tick);
			}

			if (this.characterNameRenderer !is null) {
				this.characterNameRenderer.render(tick);
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
					this.structureNameRenderer = null;
				}
				return;
			}
			// character naming
			else if (this.characterNameRenderer !is null) {
				this.characterNameRenderer.handleEvent(event);
				// if event triggered deactivation of text input renderer - delete it
				if (!this.characterNameRenderer.isActive()) {
					this.characterNameRenderer = null;
				}
				return;
			}

			this.mapRenderer.handleEvent(event);
			this.ui.handleEvent(event);
		}
}
