module map;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.stdio;
import std.string;


public class Map {
	/** variables *****************************************************/

	private byte[] tiles;
	private int width;
	private int height;

	/** constants *****************************************************/
	public static byte LAND = 0;
	public static byte WATER = 1;

	/** methods *******************************************************/

	public this(string filename) {
		this.loadFromFile(filename);
	}

	public const(byte) getTile(int i, int j) const
		in {
			assert(i >= 0, "Map::getTile");
			assert(j >= 0, "Map::getTile");
			assert(i < this.width, "Map::getTile");
			assert(j < this.height, "Map::getTile");
		}
		body {
			return this.tiles[i + j * this.width];
		}

	public const(int) getWidth() const {
		return this.width;
	}

	public const(int) getHeight() const {
		return this.height;
	}


	/**
	 * check if given position is within map bounds
	 **/
	public bool isPositionInMap(int i, int j) const {
		if (j >= 0 && i >= 0 && i < this.width && j < this.height) {
			return true;
		}

		return false;
	}

	/**
	 * check if requested tile is a land tile
	 **/
	public const(bool) isLand(int i, int j) const {
		if (this.getTile(i, j) == Map.LAND) {
			return true;
		}

		return false;
	}



	private void loadFromFile(string filename) {
		SDL_Surface *mapSurface = IMG_Load(toStringz(filename));
		assert(mapSurface !is null, "Map::loadFromFile map file not found");

		this.height = mapSurface.h;
		this.width = mapSurface.w;

		debug(1) {
			writefln("Map::loadFromFile %s w: %d, h: %d",
					 filename, this.width, this.height);
		}

		// iterate over input map data
		SDL_LockSurface(mapSurface);

		void *pixelPointer = mapSurface.pixels;
		//TODO check byte format of image
		for(int i = 0; i < this.height * this.width; ++i) {
			//tiles ~= *cast(byte*)(pixelPointer);
			if (*cast(byte*)(pixelPointer) == 0) {	// land
				this.tiles ~= Map.LAND;
			} else {								// water
				this.tiles ~= Map.WATER;
			}
			pixelPointer += mapSurface.format.BytesPerPixel;
		}

		SDL_UnlockSurface(mapSurface);
	}
}
