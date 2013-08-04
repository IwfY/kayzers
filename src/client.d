module client;

import game;
import renderhelper;
import world.nation;
import world.structureprototype;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.stdio;
import std.typecons;

public class Client {
	private Game game;
	private Rebindable!(const(Nation)) currentNation;
	private RenderHelper renderer;
	private SDL_Window *window;
	private bool active;	// player is active and can interact with the game
	private bool running;


	public this(Game game) {
		this.game = game;

		this.window = SDL_CreateWindow("Kayzers",
									   0, 0, 800, 600,
									   SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
		if (this.window is null){
			writeln(SDL_GetError());
		}

		this.renderer = new RenderHelper(this, this.window, this.game.getMap());
	}


	public ~this() {
		delete this.renderer;

		SDL_DestroyWindow(this.window);
	}


	public void addStructureHandler(string structureName) {
		//TODO: if selected region bigger 1x1 --> multiple addStructure calls
		this.game.addStructure(structureName,
							   this.currentNation,
							   this.renderer.getSelectedPosition());
	}
	
	
	public const(StructurePrototype[]) getStructurePrototypes() const {
		return this.game.getStructurePrototypes();
	}

	public const(Nation) getCurrentNation() const {
		return this.currentNation;
	}
	public void setCurrentNation(const(Nation) currentNation) {
		this.currentNation = currentNation;
	}


	public const(Game) getGame() const {
		return this.game;
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
					// end turn
					if (event.key.keysym.sym == SDLK_RETURN) {
						this.game.endTurn(this.currentNation);
					}
					debug(2) {
						writefln("The %s key was pressed!\n",
						   event.key.keysym);
					}
				}

				this.renderer.handleEvent(event);
			}

			this.renderer.render();

			int frameDuration = SDL_GetTicks() - frameStartTime;
			if (frameDuration < (1000 / MAX_FRAMES_PER_SECOND)) {
				SDL_Delay(( 1000 / MAX_FRAMES_PER_SECOND ) - frameDuration );
			}
		}
	}

}
