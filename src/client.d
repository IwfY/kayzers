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
	private SDL_Rect *selectedRegion;
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

		this.selectedRegion = new SDL_Rect();
		this.renderer = new Renderer(this, this.window);

		this.renderer.registerTexture("grass", "resources/img/grass_n.png");
		this.renderer.registerTexture("water", "resources/img/water_n.png");
		this.renderer.registerTexture("border",
									  "resources/img/grid_border.png");
		this.renderer.registerTexture("cursor",
									  "resources/img/grid_cursor.png");
		this.renderer.registerTexture("ui_background",
									  "resources/img/ui_background.png");
		//TODO make portable
		this.renderer.registerFont("std", 
								   "/usr/share/fonts/TTF/DejaVuSans.ttf");

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

		this.renderer.render(mousePosition, this.selectedRegion);

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
					} else if (event.key.keysym.sym == SDLK_KP_5) {
						this.renderer.panToTile(
								cast(int)(this.game.getMap().getWidth() / 2),
								cast(int)(this.game.getMap().getHeight() / 2));
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
				} else if (event.type == SDL_MOUSEBUTTONDOWN &&
						event.button.button == SDL_BUTTON_LEFT) {
					mousePosition.x = event.button.x;
					mousePosition.y = event.button.y;
					this.renderer.getTileAtPixel(mousePosition,
												 this.selectedRegion.x,
												 this.selectedRegion.y);
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

			this.renderer.render(mousePosition, this.selectedRegion);

			int frameDuration = SDL_GetTicks() - frameStartTime;
			if (frameDuration < (1000 / MAX_FRAMES_PER_SECOND)) {
				SDL_Delay(( 1000 / MAX_FRAMES_PER_SECOND ) - frameDuration );
			}
		}
	}

}
