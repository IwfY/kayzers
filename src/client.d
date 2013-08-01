module client;

import game;
import renderhelper;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.stdio;

public class Client {
	private Game game;
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

		this.renderer.registerTexture("grass", "resources/img/grass_n.png");
		this.renderer.registerTexture("water", "resources/img/water_n.png");
		this.renderer.registerTexture("border",
									  "resources/img/grid_border.png");
		this.renderer.registerTexture("cursor",
									  "resources/img/grid_cursor.png");
		this.renderer.registerTexture("ui_background",
									  "resources/img/ui_background.png");
		this.renderer.registerTexture("button_default",
									  "resources/img/ui/button_default.png");
		//TODO make portable
		this.renderer.registerFont("std",
								   "/usr/share/fonts/TTF/DejaVuSans.ttf");
	}


	public ~this() {
		delete this.renderer;

		SDL_DestroyWindow(this.window);
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

			this.renderer.render();

			int frameDuration = SDL_GetTicks() - frameStartTime;
			if (frameDuration < (1000 / MAX_FRAMES_PER_SECOND)) {
				SDL_Delay(( 1000 / MAX_FRAMES_PER_SECOND ) - frameDuration );
			}
		}
	}

}
