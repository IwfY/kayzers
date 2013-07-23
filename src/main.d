import renderer;
import map;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.stdio;
import std.string;

int main(string[] args) {
	DerelictSDL2.load();
	DerelictSDL2Image.load();

	if (args.length < 2) {
		writeln("open: ./kayzers <<image>>");
		return 0;
	}

	Map map;
	Renderer renderer;

	if (SDL_Init(SDL_INIT_EVERYTHING) == -1){
		writeln(SDL_GetError());
		return 1;
	}

	SDL_Window *window;
	window = SDL_CreateWindow("Kayzers", 100, 100, 800, 600, SDL_WINDOW_SHOWN);
	if (window is null){
		writeln(SDL_GetError());
		return 1;
	}

	renderer = new Renderer(window);

	renderer.registerTexture("grass", "resources/img/grass_n.png");
	renderer.registerTexture("water", "resources/img/water_n.png");
	renderer.registerTexture("border", "resources/img/grid_border.png");

	map = new Map(args[1]);
	renderer.setMap(map);

	bool mousePressed = false;
	SDL_Point *mousePressedPosition = new SDL_Point(0, 0);
	SDL_Point *mousePosition = new SDL_Point(0, 0);

	renderer.render(mousePosition);

	const int MAX_FRAMES_PER_SECOND = 60;
	
	SDL_Event event;
	int frameStartTime;

	bool quit = false;
	while (!quit) {
		frameStartTime = SDL_GetTicks();
		//Event Polling
		while (SDL_PollEvent(&event)) {
			//If user closes the window
			if (event.type == SDL_QUIT) {
				quit = true;
			}
			if (event.type == SDL_KEYDOWN) {
				if (event.key.keysym.sym == SDLK_q) {
					quit = true;
				} else if (event.key.keysym.sym == SDLK_1) {
					renderer.setZoom(1);
				} else if (event.key.keysym.sym == SDLK_2) {
					renderer.setZoom(2);
				} else if (event.key.keysym.sym == SDLK_3) {
					renderer.setZoom(3);
				} else if (event.key.keysym.sym == SDLK_4) {
					renderer.setZoom(4);
				} else if (event.key.keysym.sym == SDLK_5) {
					renderer.setZoom(12);
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
					renderer.moveOffset(
							event.motion.x - mousePressedPosition.x,
							event.motion.y - mousePressedPosition.y);
					mousePressedPosition.x = event.motion.x;
					mousePressedPosition.y = event.motion.y;
				}
			}
		}

		renderer.render(mousePosition);

		int frameDuration = SDL_GetTicks() - frameStartTime;
		if (frameDuration < (1000 / MAX_FRAMES_PER_SECOND)) {
			SDL_Delay(( 1000 / MAX_FRAMES_PER_SECOND ) - frameDuration );
		}
	}

	delete renderer;

	SDL_DestroyWindow(window);

	SDL_Quit();

	DerelictSDL2Image.unload();
	DerelictSDL2.unload();

	return 0;
}
