import client;
import game;
import map;
import world.nation;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import derelict.sdl2.image;

import std.stdio;
import std.string;

int main(string[] args) {
	if (args.length < 2) {
		writeln("open: ./kayzers <<image>>");
		return 0;
	}

	DerelictSDL2.load();
	DerelictSDL2Image.load();
	DerelictSDL2ttf.load();

	if (SDL_Init(SDL_INIT_EVERYTHING) == -1){
		writeln(SDL_GetError());
		return 1;
	}

	if (TTF_Init() == -1){
		writeln(TTF_GetError());
		return 1;
	}

	Client client;
	client = new Client();
	client.run();
	delete client;

	TTF_Quit();
	SDL_Quit();

	DerelictSDL2.unload();
	DerelictSDL2Image.unload();
	DerelictSDL2ttf.unload();

	return 0;
}
