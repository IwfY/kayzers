import client;
import game;
import map;

import derelict.sdl2.sdl;
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

	if (SDL_Init(SDL_INIT_EVERYTHING) == -1){
		writeln(SDL_GetError());
		return 1;
	}

	Game game;
	Client client;
	Map map;
	map = new Map(args[1]);
	game = new Game();
	game.setMap(map);
	
	client = new Client(game);
	game.addClient(client);

	client.run();
	
	SDL_Quit();
	writefln("sdl quited");
	
	DerelictSDL2.unload();
	DerelictSDL2Image.unload();

	return 0;
}
