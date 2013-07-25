module client;

import game;
import renderer;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.stdio;

public class Client {
	private Game game;
	private Renderer renderer;
	private SDL_Window *window;
	private bool active;	// player is active and can interact with the game
	private bool running;


	public this(Game game) {
		this.game = game;

		this.window = SDL_CreateWindow("Kayzers",
									   100, 100, 800, 600,
									   SDL_WINDOW_SHOWN);
		if (this.window is null){
			writeln(SDL_GetError());
		}

		this.renderer = new Renderer(this, this.window);

		this.renderer.registerTexture("grass", "resources/img/grass_n.png");
		this.renderer.registerTexture("water", "resources/img/water_n.png");
		this.renderer.registerTexture("border",
									   "resources/img/grid_border.png");

		this.renderer.setMap(this.game.getMap());
	}


	public ~this() {
		delete this.renderer;

		SDL_DestroyWindow(this.window);
	}


	public void run() {
		bool mousePressed = false;
		SDL_Point *mousePressedPosition = new SDL_Point(0, 0);
		SDL_Point *mousePosition = new SDL_Point(0, 0);

		this.renderer.render(mousePosition);

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
					} else if (event.key.keysym.sym == SDLK_1) {
						this.renderer.setZoom(1);
					} else if (event.key.keysym.sym == SDLK_2) {
						this.renderer.setZoom(2);
					} else if (event.key.keysym.sym == SDLK_3) {
						this.renderer.setZoom(3);
					} else if (event.key.keysym.sym == SDLK_4) {
						this.renderer.setZoom(4);
					} else if (event.key.keysym.sym == SDLK_5) {
						this.renderer.setZoom(12);
					}

					debug(2) {
						writefln("The %s key was pressed!\n",
						   event.key.keysym);
					}
				}

				if (event.type == SDL_MOUSEBUTTONDOWN &&
					event.button.button == SDL_BUTTON_RIGHT) {
					mousePressed = true;
					mousePressedPosition.x = event.button.x;
					mousePressedPosition.y = event.button.y;
				} else if (event.type == SDL_MOUSEBUTTONUP &&
					event.button.button == SDL_BUTTON_RIGHT) {
					mousePressed = false;
				} else if (event.type == SDL_MOUSEMOTION) {
					mousePosition.x = event.motion.x;
					mousePosition.y = event.motion.y;
					if (mousePressed) {
						this.renderer.moveOffset(
								event.motion.x - mousePressedPosition.x,
								event.motion.y - mousePressedPosition.y);
						mousePressedPosition.x = event.motion.x;
						mousePressedPosition.y = event.motion.y;
					}
				}
			}

			this.renderer.render(mousePosition);

			int frameDuration = SDL_GetTicks() - frameStartTime;
			if (frameDuration < (1000 / MAX_FRAMES_PER_SECOND)) {
				SDL_Delay(( 1000 / MAX_FRAMES_PER_SECOND ) - frameDuration );
			}
		}
	}

}
