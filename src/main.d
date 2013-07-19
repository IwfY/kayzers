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
	
	renderer.registerTexture("grass", "resources/img/grass.png");
	renderer.registerTexture("water", "resources/img/water.png");
	
	renderer.loadMap("resources/img/map.png");
	
	int offsetX = 0;
	int offsetY = 0;
	SDL_Rect *offset = new SDL_Rect(0, 0);
	int mousePressedX = 0;
	int mousePressedY = 0;
	bool mousePressed = false;
	SDL_Point *mousePosition = new SDL_Point(0, 0);
	renderer.render(offset);
	
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
				}
				writefln("The %s key was pressed!\n",
                   event.key.keysym);
			}
			
			if (event.type == SDL_MOUSEBUTTONDOWN &&
				event.button.button == SDL_BUTTON_RIGHT) {
				mousePressed = true;
				mousePressedX = event.button.x - offset.x;
				mousePressedY = event.button.y - offset.y;
			} else if (event.type == SDL_MOUSEBUTTONUP &&
				event.button.button == SDL_BUTTON_RIGHT) {
				mousePressed = false;
			} else if (event.type == SDL_MOUSEMOTION) {
				mousePosition.x = event.motion.x;
				mousePosition.y = event.motion.y;
				if (mousePressed) {
					offset.x = event.motion.x - mousePressedX;
					offset.y = event.motion.y - mousePressedY;
				}
			}
		}
		
		renderer.render(offset);
		
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
