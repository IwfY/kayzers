import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.stdio;
import std.string;

SDL_Texture *LoadImage(string file, SDL_Renderer *renderer) {
	SDL_Texture *tex = null;
	tex = IMG_LoadTexture(renderer, toStringz(file));
	if (tex is null) {
		writeln("failed to load texture");
	}
	return tex;
}

void render(SDL_Texture *texture,
			SDL_Renderer *renderer,
			int offsetX,
			int offsetY) {
	//Clear the window
	SDL_RenderClear(renderer);
	
	int tileWidth = 72;
	int tileHeight = 34;
	for(int i = 0; i < 10; ++i) {
		for (int j = 0; j < 10; ++j) {
			ApplySurface(
				offsetX + j * tileWidth,
				offsetY + i * tileHeight,
				texture, renderer);
			ApplySurface(
				offsetX + j * tileWidth + cast(int)(tileWidth / 2),
				offsetY + i * tileHeight + cast(int)(tileHeight / 2),
				texture, renderer);
		}
	}
	
	//Update the screen
	SDL_RenderPresent(renderer);
}

void ApplySurface(int x, int y, SDL_Texture *tex, SDL_Renderer *rend){
	//First we must create an SDL_Rect for the position of the image, as SDL
	//won't accept raw coordinates as the image's position
	SDL_Rect pos;
	pos.x = x;
	pos.y = y;
	//We also need to query the texture to get its width and height to use
	SDL_QueryTexture(tex, null, null, &pos.w, &pos.h);
	SDL_RenderCopy(rend, tex, null, &pos);
}

int main(string[] args) {
	DerelictSDL2.load();
	DerelictSDL2Image.load();
	
	//First we need to start up SDL, and make sure it went ok
	if (SDL_Init(SDL_INIT_EVERYTHING) == -1){
		writeln(SDL_GetError());
		return 1;
	}

	//First we need to create a window to draw things in
	SDL_Window *win;
	//Create a window with title "Hello World" at 100, 100 on the screen with w:640 h:480 and show it
	win = SDL_CreateWindow("Kayzers", 100, 100, 640, 480, SDL_WINDOW_SHOWN);
	//Make sure creating our window went ok
	if (win is null){
		writeln(SDL_GetError());
		return 1;
	}

	//Now we create our renderer
	SDL_Renderer *ren;
	//Create a renderer that will draw to window, -1 specifies that we want to load whichever 
	//video driver supports the flags we're passing
	//Flags: SDL_RENDERER_ACCELERATED: We want to use hardware accelerated rendering, b/c it rocks!
	//SDL_RENDERER_PRESENTVSYNC: We want the renderer's present function (update screen) to be
	//synchornized with the monitor's refresh rate
	ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
	if (ren is null){
		writeln(SDL_GetError());
		return 1;
	}
	
	SDL_Texture *image;
	image = LoadImage("resources/img/grid_72_34.png", ren);
	
	int offsetX = 0;
	int offsetY = 0;
	int mouseX = 0;
	int mouseY = 0;
	bool mousePressed = false;
	render(image, ren, offsetX, offsetY);
	
	//For tracking if we want to quit
	SDL_Event event;
	
	bool quit = false;
	while (!quit) {
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
				mouseX = event.button.x - offsetX;
				mouseY = event.button.y - offsetY;
			} else if (event.type == SDL_MOUSEBUTTONUP &&
				event.button.button == SDL_BUTTON_RIGHT) {
				mousePressed = false;
			} else if (event.type == SDL_MOUSEMOTION) {
				if (mousePressed) {
					offsetX = event.motion.x - mouseX;
					offsetY = event.motion.y - mouseY;
				}
			}
		}
		
		render(image, ren, offsetX, offsetY);
	}
	
	SDL_DestroyTexture(image);
	SDL_DestroyRenderer(ren);
	SDL_DestroyWindow(win);
	
	SDL_Quit();
	
	DerelictSDL2Image.unload();
	DerelictSDL2.unload();

	return 0;
}
