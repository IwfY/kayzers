import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.stdio;

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
		
	SDL_Surface *surface;
	surface = IMG_Load("resources/img/4color.png");
	
	void *pixelPointer = surface.pixels;
	for (int i = 0; i < surface.w * surface.h; ++i) {
		writefln("r (%02X), g (%02X), b (%02X), a (%02X)",
			     *cast(byte*)(pixelPointer++),
			     *cast(byte*)(pixelPointer++),
			     *cast(byte*)(pixelPointer++),
			     *cast(byte*)(pixelPointer++));
	}
	
	SDL_FreeSurface(surface);
	SDL_DestroyWindow(win);
	
	SDL_Quit();
	
	DerelictSDL2Image.unload();
	DerelictSDL2.unload();

	return 0;
}
