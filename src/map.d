module map;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.stdio;
import std.string;

public class Map {
	/** variables *****************************************************/
	
	private byte[] tiles;
	private uint width;
	private uint height;


	/** methods *******************************************************/

	public this(string filename) {
		this.loadFromFile(filename);
	}
	
	public byte getTile(int x, int y)
		in {
			assert(x >= 0, "Map::getTile");
			assert(y >= 0, "Map::getTile");
			assert(x < this.width, "Map::getTile");
			assert(y < this.height, "Map::getTile");
		}
		body {
			return this.tiles[y + x * this.height];
		}
	
	public uint getWidth() {
		return this.width;
	}
	
	public uint getHeight() {
		return this.height;
	}
	
	private void loadFromFile(string filename) {
		SDL_Surface *mapSurface = IMG_Load(toStringz(filename));
		assert(mapSurface !is null);
		
		this.height = mapSurface.h;
		this.width = mapSurface.w;
		
		debug(2) {
			writefln("Map::loadFromFile w: %d, h: %d",
					 this.width, this.height);
		}
		
		// iterate over input map data
		SDL_LockSurface(mapSurface);

		void *pixelPointer = mapSurface.pixels;
		//TODO check byte format of image
		for(int i = 0; i < this.height * this.width; ++i) {
			//tiles ~= *cast(byte*)(pixelPointer);
			if (*cast(byte*)(pixelPointer) == 0) {	// land
				this.tiles ~= 0;
			} else {								// water
				this.tiles ~= 1;
			}
			pixelPointer += 4;
		}

		SDL_UnlockSurface(mapSurface);
	}
}
