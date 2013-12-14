module ui.ingamerenderer;

import client;
import message;
import messagebroker;
import observer;
import ui.characterinforenderer;
import ui.characternamerenderer;
import ui.renderer;
import ui.renderhelper;
import ui.maprenderer;
import ui.notificationrenderer;
import ui.proposalreplyrenderer;
import ui.resourceloader;
import ui.structurenamerenderer;
import ui.ui;
import world.character;
import world.structure;

import derelict.sdl2.sdl;

import std.array;
import std.typecons;

class InGameRenderer : Renderer, Observer {
	private UI ui;
	private MapRenderer mapRenderer;
	private StructureNameRenderer structureNameRenderer;
	private CharacterNameRenderer characterNameRenderer;
	private NotificationRenderer notificationRenderer;
	private CharacterInfoRenderer characterInfoRenderer;
	private ProposalReplyRenderer proposalReplyRenderer;

	private const(Character)[] charactersToName;
	private Tuple!(int, int)[] proposalsToReply;

	private MessageBroker messageBroker;


	public this(Client client, RenderHelper renderer,
				MessageBroker messageBroker) {
		super(client, renderer);

		this.messageBroker = messageBroker;
		this.messageBroker.register(this, "gameStarted");
		this.messageBroker.register(this, "gameStopped");
		this.messageBroker.register(this, "nameCharacter");
		this.messageBroker.register(this, "proposal");
	}


	public ~this() {
		this.messageBroker.unregister(this, "gameStarted");
		this.messageBroker.unregister(this, "gameStopped");
		this.messageBroker.unregister(this, "nameCharacter");
		this.messageBroker.unregister(this, "proposal");

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

		if (this.characterInfoRenderer !is null) {
			destroy(this.characterInfoRenderer);
		}

		if (this.proposalReplyRenderer !is null) {
			destroy(this.proposalReplyRenderer);
		}
	}


	public void startProposalReplyRenderer(Tuple!(int, int) characterIds) {
		this.proposalReplyRenderer = new ProposalReplyRenderer(
			this.client, this.renderer, characterIds[0], characterIds[1]);
	}

	public void startStructureNameRenderer(const(Structure) structure) {
		this.structureNameRenderer = new StructureNameRenderer(
			this.client, this.renderer, structure);
	}

	public void startCharacterNameRenderer(const(Character) character) {
		this.characterNameRenderer = new CharacterNameRenderer(
			this.client, this.renderer, character);
	}

	public void startCharacterInfoRenderer(const(Character) character) {
		this.characterInfoRenderer = new CharacterInfoRenderer(
			this.client, this.renderer, character);
	}


	public override void notify(const(Message) message) {
		// a game was started
		if (message.text == "gameStarted") {
			// load game specific assets
			ResourceLoader.loadGameTextures(this.client.getServerStub(), this.renderer);

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
			this.charactersToName ~= character;
		}

		// proposal sent
		else if (message.text == "proposal") {
			assert(typeid(message) == typeid(ObjectMessage!(Tuple!(int, int))));
			ObjectMessage!(Tuple!(int, int)) objectMessage =
				cast(ObjectMessage!(Tuple!(int, int)))message;

			this.proposalsToReply ~= objectMessage.object;
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

		if (this.characterInfoRenderer !is null) {
			this.characterInfoRenderer.setScreenRegion(
				this.screenRegion.x, this.screenRegion.y,
				this.screenRegion.w, this.screenRegion.h);
		}

		if (this.proposalReplyRenderer !is null) {
			this.proposalReplyRenderer.setScreenRegion(
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
			// check whether a proposal needs to be replied to
			if (this.proposalReplyRenderer is null &&
		   			this.proposalsToReply.length > 0) {
				Tuple!(int, int) ids = this.proposalsToReply.front!(Tuple!(int, int))();
				this.proposalsToReply.popFront();
				this.startProposalReplyRenderer(ids);
			}
			// check whether a character should be named
			else if (this.characterNameRenderer is null &&
					this.charactersToName.length > 0) {
				const(Character) characterToName = this.charactersToName.front!(const(Character))();
				this.charactersToName.popFront();
				this.startCharacterNameRenderer(characterToName);
			}

			this.updateRendererDrawRegions();
			this.mapRenderer.render(tick);
			this.ui.render(tick);
			this.notificationRenderer.render(tick);

			// structure naming
			if (this.structureNameRenderer !is null) {
				this.structureNameRenderer.render(tick);
			}
			// character naming
			else if (this.characterNameRenderer !is null) {
				this.characterNameRenderer.render(tick);
			}
			// character info
			else if (this.characterInfoRenderer !is null) {
				this.characterInfoRenderer.render(tick);
			}
			// proposal reply
			else if(this.proposalReplyRenderer !is null) {
				this.proposalReplyRenderer.render(tick);
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
				// if event triggered deactivation of renderer - delete it
				if (!this.structureNameRenderer.isActive()) {
					this.structureNameRenderer = null;
				}
				return;
			}
			// character naming
			else if (this.characterNameRenderer !is null) {
				this.characterNameRenderer.handleEvent(event);
				// if event triggered deactivation of renderer - delete it
				if (!this.characterNameRenderer.isActive()) {
					this.characterNameRenderer = null;
				}
				return;
			}
			// character info
			else if (this.characterInfoRenderer !is null) {
				this.characterInfoRenderer.handleEvent(event);
				// if event triggered deactivation of renderer - delete it
				if (!this.characterInfoRenderer.isActive()) {
					this.characterInfoRenderer = null;
				}
				return;
			}
			// proposal reply
			else if (this.proposalReplyRenderer !is null) {
				this.proposalReplyRenderer.handleEvent(event);
				// if event triggered deactivation of renderer - delete it
				if (!this.proposalReplyRenderer.isActive()) {
					this.proposalReplyRenderer = null;
				}
				return;
			}

			this.mapRenderer.handleEvent(event);
			this.ui.handleEvent(event);

			if (event.type == SDL_KEYDOWN) {
				// enter input
				if (event.key.keysym.sym == SDLK_ESCAPE) {
					this.client.stop();
				}
			}
		}
}
