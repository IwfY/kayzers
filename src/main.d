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
	
	//Clear the window
	SDL_RenderClear(ren);
	
	int tileWidth = 72;
	int tileHeight = 34;
	for(int i = 0; i < 10; ++i) {
		for (int j = 0; j < 10; ++j) {
			ApplySurface(j * tileWidth, i * tileHeight, image, ren);
			ApplySurface(j * tileWidth + cast(int)(tileWidth / 2), i * tileHeight + cast(int)(tileHeight / 2), image, ren);
		}
	}
	
	//Update the screen
	SDL_RenderPresent(ren);
	SDL_Delay(2000);
	
	SDL_DestroyTexture(image);
	SDL_DestroyRenderer(ren);
	SDL_DestroyWindow(win);
	
	SDL_Quit();
	
	DerelictSDL2Image.unload();
	DerelictSDL2.unload();

	return 0;
}
