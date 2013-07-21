import renderer;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.stdio;
import std.string;

int main(string[] args) {
	DerelictSDL2.load();
	DerelictSDL2Image.load();

	Renderer renderer;

	//First we need to start up SDL, and make sure it went ok
	if (SDL_Init(SDL_INIT_EVERYTHING) == -1){
		writeln(SDL_GetError());
		return 1;
	}

	//First we need to create a window to draw things in
	SDL_Window *window;
	//Create a window with title "Hello World" at 100, 100 on the screen with w:640 h:480 and show it
	window = SDL_CreateWindow("Kayzers", 100, 100, 800, 600, SDL_WINDOW_SHOWN);
	//Make sure creating our window went ok
	if (window is null){
		writeln(SDL_GetError());
		return 1;
	}

	renderer = new Renderer(window);

	renderer.registerTexture("grass", "resources/img/grass_n.png");
	renderer.registerTexture("water", "resources/img/water_n.png");
	renderer.registerTexture("border", "resources/img/grid_border.png");

	renderer.loadMap("resources/img/map.png");

	bool mousePressed = false;
	SDL_Point *mousePressedPosition = new SDL_Point(0, 0);
	SDL_Point *mousePosition = new SDL_Point(0, 0);

	renderer.render(mousePosition);

	const int MAX_FRAMES_PER_SECOND = 60;

	//For tracking if we want to quit
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
