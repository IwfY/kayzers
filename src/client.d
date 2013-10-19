module client;

import game;
import map;
import messagebroker;
import position;
import ui.renderer;
import ui.rendererfactory;
import world.nation;
import world.nationprototype;
import world.scenario;
import world.structure;
import world.structureprototype;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.stdio;
import std.typecons;

public class Client {
	private Game game;
	private Renderer renderer;
	private SDL_Window *window;
	private bool gameActive;
	private bool running;
	private Scenario[string] scenarios;
	private MessageBroker messageBroker;


	public this() {
		this.window = SDL_CreateWindow("Kayzers",
									   0, 0, 1024, 740,
									   SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
		if (this.window is null){
			writeln(SDL_GetError());
		}

		this.messageBroker = new MessageBroker();
		this.gameActive = false;

		this.renderer = RendererFactory.makeRenderInfrastructure(
				this, this.window, this.messageBroker);

		this.scenarios = ScenarioLoader.loadScenarios("resources/scenarios");
	}


	public ~this() {
		destroy(this.renderer);

		SDL_DestroyWindow(this.window);
	}


	public bool startGame(string scenarioName) {
		if (this.scenarios.get(scenarioName, null) is null) {
			return false;
		}

		this.game = new Game(this, this.scenarios[scenarioName]);
		this.game.startNewRound();

		this.gameActive = true;
		this.messageBroker.notify("gameStarted");
		this.messageBroker.notify("nationChanged");

		return true;
	}

	public void stopGame() {
		this.gameActive = false;
		this.messageBroker.notify("gameStopped");
	}


	/**
	 * publishes a notification from the server (Game) to the message broker
	 **/
	public void serverNotify(string message) {
		this.messageBroker.notify(message);
	}

	/**
	 * returns true if a game is active
	 **/
	public bool isGameActive() {
		return this.gameActive;
	}


	public const(StructurePrototype[]) getStructurePrototypes() const {
		return this.game.getStructurePrototypes();
	}

	public const(NationPrototype[]) getNationPrototypes() const {
		return this.game.getNationPrototypes();
	}


	public const(Nation[]) getNations() const {
		return this.game.getNations();
	}


	public const(Nation) getCurrentNation() const {
		return this.game.getCurrentNation();
	}


	public bool canBuildStructure(string structurePrototypeName,
								  const(Nation) nation,
								  const(Position) position) const {
		return this.game.canBuildStructure(
			structurePrototypeName, nation, position);
	}


	public void setStructureName(const(Structure) structure, string name) {
		this.game.setStructureName(structure, name);
	}


	public bool addStructure(string structurePrototypeName,
							 const(Nation) nation,
							 const(Position) position) {
		return this.game.addStructure(structurePrototypeName, nation, position);
	}

	public const(Structure[]) getStructures() const {
		return this.game.getStructures();
	}
	public const(Structure) getStructure(int i, int j) const {
		return this.game.getStructure(i, j);
	}

	public const(Map) getMap() const {
		return this.game.getMap();
	}

	public const(int) getCurrentYear() const {
		return this.game.getCurrentYear();
	}


	public void stop() {
		this.running = false;
	}

	public void endTurn() {
		this.game.endTurn();
	}


	/**
	 * client main loop
	 **/
	public void run() {
		this.renderer.render();

		const int MAX_FRAMES_PER_SECOND = 60;

		SDL_Event event;
		int frameStartTime;

		this.running = true;
		int tick = 0;
		while (this.running) {
			frameStartTime = SDL_GetTicks();
			while (SDL_PollEvent(&event)) {
				if (event.type == SDL_QUIT) {
					this.running = false;
				}

				if (event.type == SDL_KEYDOWN) {
					// quit
					if (event.key.keysym.sym == SDLK_q) {
						this.running = false;
					}
					debug(2) {
						writefln("The %s key was pressed!\n",
						   event.key.keysym);
					}
				}

				this.renderer.handleEvent(event);
			}

			this.renderer.render(tick);
			++tick;

			int frameDuration = SDL_GetTicks() - frameStartTime;
			if (frameDuration < (1000 / MAX_FRAMES_PER_SECOND)) {
				SDL_Delay(( 1000 / MAX_FRAMES_PER_SECOND ) - frameDuration );
			}
		}
	}

}
