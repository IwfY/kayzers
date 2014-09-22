module client;

import game;
import message;
import messagebroker;
import serverstub;
import ui.renderer;
import ui.rendererfactory;
import world.scenario;

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
	private ServerStub serverStub;

	public this() {
		this.window = SDL_CreateWindow("Kayzers",
									   0, 0, 1024, 740,
									   SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
		if (this.window is null){
			writeln(SDL_GetError());
		}

		this.messageBroker = new MessageBroker();
		this.gameActive = false;

		this.scenarios = ScenarioLoader.loadScenarios("resources/scenarios");

		this.renderer = RendererFactory.makeRenderInfrastructure(
				this, this.window, this.messageBroker);
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
		this.serverStub = new ServerStub(this.game);

		this.game.startNewRound();

		this.gameActive = true;
		this.messageBroker.notify(new Message("gameStarted"));
		this.messageBroker.notify(new Message("nationChanged"));

		return true;
	}


	public void stopGame() {
		this.gameActive = false;
		this.messageBroker.notify(new Message("gameStopped"));
	}


	/**
	 * publishes a notification from the server (Game) to the message broker
	 **/
	public void serverNotify(const(Message) message) {
		this.messageBroker.notify(message);
	}

	/**
	 * returns true if a game is active
	 **/
	public bool isGameActive() {
		return this.gameActive;
	}


	/**
	 * get the internationalized string for a given one
	 **/
	public const(string) getI18nString(string text) const {
		return text;	// dummy just echo
	}


	public const(Scenario[]) getScenarios() const {
		return this.scenarios.values;
	}


	public ServerStub getServerStub() {
		return this.serverStub;
	}
	public const(ServerStub) getServerStub() const {
		return this.serverStub;
	}


	public void stop() {
		this.running = false;
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
