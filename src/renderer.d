module renderer;

import map;
import utils;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.stdio;
import std.string;
import std.math;


struct TextureWrapper {
	public SDL_Surface *surface;
	public SDL_Texture *texture;
}


class Renderer {
	private Map map;
	private SDL_Renderer *renderer;
	private TextureWrapper*[string] textures;
	private SDL_Window *window;
	private SDL_Rect *tileDimensions;

	// offset is added to the tile position when drawing
	private SDL_Point *offset;
	private int zoom;


	public this(SDL_Window *window) {
		this.window = window;

		this.renderer = SDL_CreateRenderer(
				this.window,
				-1,
				SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
		if (this.renderer is null) {
			writeln(SDL_GetError());
		}

		this.offset = new SDL_Point(0, 0);
		this.tileDimensions = new SDL_Rect(0, 0);
		this.tileDimensions.w = 120;
		this.tileDimensions.h = 70;
		this.zoom = 1;
	}


	public ~this() {
		SDL_DestroyRenderer(this.renderer);

		// destroy textures
		string[] keys = this.textures.keys;
		for (int i = 0; i < keys.length; ++i) {
			string key = keys[i];
			SDL_Texture *texture = this.getTexture(key);
			this.textures.remove(key);
			SDL_DestroyTexture(texture);
		}
	}


	/**
	 * load an image file representing the map and prerender the map to
	 * a surface
	 **/
	public void setMap(Map map) {
		this.map = map;
	}


	/**
	 * load a texture from a file and make it accessible through the texture map
	 *
	 * @param textureName key to the texture map
	 * @param filename path to the texture to load
	 **/
	public bool registerTexture(const string textureName,
							    const string filename) {
		if (this.renderer is null) {
			return false;
		}

		TextureWrapper *tex = new TextureWrapper();
		tex.surface = IMG_Load(toStringz(filename));
		if (tex.surface is null) {
			return false;
		}
		tex.texture = SDL_CreateTextureFromSurface(this.renderer,
							tex.surface);
		if (tex.texture is null) {
			return false;
		}

		this.textures[textureName] = tex;

		debug(2) {
			writefln("Renderer::registerTexture Load %s as %s",
					filename, textureName);
		}

		return true;
	}


	public SDL_Texture *getTexture(const string textureName) {
		// TODO: check if texture available
		return this.textures[textureName].texture;
	}

	public SDL_Surface *getSurface(const string textureName) {
		// TODO: check if texture available
		return this.textures[textureName].surface;
	}

	/**
	 * draw a texture to the renderer
	 **/
	private void drawTexture(int x, int y, SDL_Texture *texture) {
		SDL_Rect position;
		position.x = x;
		position.y = y;

		SDL_QueryTexture(texture, null, null, &position.w, &position.h);

		debug(2) {
			writefln("Renderer::drawTexture %d, %d, %d, %d",
					 position.x, position.y, position.w, position.h);
		}

		SDL_RenderCopy(this.renderer, texture, null, &position);
	}


	private void drawTile(int x, int y, SDL_Texture *texture) {
		SDL_Rect position;
		position.x = x;
		position.y = y;

		position.w = cast(int)(
			ceil(cast(double)this.tileDimensions.w / cast(double)this.zoom));
		position.h = cast(int)(
			ceil(cast(double)this.tileDimensions.h / cast(double)this.zoom));

		SDL_RenderCopy(this.renderer, texture, null, &position);
	}


	/**
	 * get the tile coordinate for a given screen position
	 *
	 * TODO: distance function could be weighted depending on tile
	 * 		 dimension
	 **/
	private void getTileAtPixel(SDL_Point *position,
								out int i, out int j) {
		double tileWidth =
				cast(double)this.tileDimensions.w /
				cast(double)this.zoom;
		double tileHeight =
				cast(double)this.tileDimensions.h /
				cast(double)this.zoom;

		double offsetX =
				cast(double)this.offset.x /
				cast(double)this.zoom;
		double offsetY =
				cast(double)this.offset.y /
				cast(double)this.zoom;

		double nearestJ = (position.y -
				offsetY - 0.5 * tileHeight) * 2.0 / tileHeight;
		double nearestI = (position.x - offsetX +
				(nearestJ - 1.0) * 0.5 * tileWidth) / tileWidth;

		int x, y;
		double distance, minDistance;
		// check for distances to 4 surounding tiles
		this.getTopLeftScreenCoordinate(
			cast(int)floor(nearestI), cast(int)floor(nearestJ), x, y);
		x += 0.5 * tileWidth;
		y += 0.5 * tileHeight;
		minDistance = getDistance(position.x, position.y, x, y);
		i = cast(int)floor(nearestI);
		j = cast(int)floor(nearestJ);

		this.getTopLeftScreenCoordinate(
			cast(int)floor(nearestI), cast(int)ceil(nearestJ), x, y);
		x += 0.5 * tileWidth;
		y += 0.5 * tileHeight;
		distance = getDistance(position.x, position.y, x, y);
		if (distance < minDistance) {
			minDistance = distance;
			i = cast(int)floor(nearestI);
			j = cast(int)ceil(nearestJ);
		}

		this.getTopLeftScreenCoordinate(
			cast(int)ceil(nearestI), cast(int)floor(nearestJ), x, y);
		x += 0.5 * tileWidth;
		y += 0.5 * tileHeight;
		distance = getDistance(position.x, position.y, x, y);
		if (distance < minDistance) {
			minDistance = distance;
			i = cast(int)ceil(nearestI);
			j = cast(int)floor(nearestJ);
		}

		this.getTopLeftScreenCoordinate(
			cast(int)ceil(nearestI), cast(int)ceil(nearestJ), x, y);
		x += 0.5 * tileWidth;
		y += 0.5 * tileHeight;
		distance = getDistance(position.x, position.y, x, y);
		if (distance < minDistance) {
			minDistance = distance;
			i = cast(int)ceil(nearestI);
			j = cast(int)ceil(nearestJ);
		}

		debug(2) {
			writefln("Renderer::getTileAtPixel i: %d, j: %d", i, j);
		}
	}


	/**
	 * get the top left coordinate of a tile drawn in column i, row j
	 **/
	private void getTopLeftScreenCoordinate(int i, int j,
											out int x, out int y) {
		double tileWidth =
				cast(double)this.tileDimensions.w /
				cast(double)this.zoom;
		double tileHeight =
				cast(double)this.tileDimensions.h /
				cast(double)this.zoom;

		double offsetX =
				cast(double)this.offset.x /
				cast(double)this.zoom;
		double offsetY =
				cast(double)this.offset.y /
				cast(double)this.zoom;

		x = cast(int)(offsetX + i * tileWidth - j * 0.5 * tileWidth);
		y = cast(int)(offsetY + j * 0.5 * tileHeight);

		debug(3) {
			writefln("Renderer::getTopLeftScreenCoordinate i: %d, j: %d --> x: %d, y:%d",
					 i, j, x, y);
		}
	}


	/**
	 * center preserving zoom
	 *
	 * @param zoom ... zoom level
	 * 				   	1 ... close
	 * 					4 ... far
	 **/
	public void setZoom(int zoom)
		in {
			assert(zoom >= 1 && zoom <= 12,
				   "Renderer::setZoom Invalid zoom level");
		}
		body {
			int windowWidth, windowHeight;
			int centerIOld, centerJOld, centerINew, centerJNew;
			SDL_Rect *mapRegion = this.getMapScreenRegion();
			this.getTileAtPixel(
					new SDL_Point(mapRegion.w / 2, mapRegion.h / 2),
					centerIOld, centerJOld);
			this.zoom = zoom;
			this.getTileAtPixel(
					new SDL_Point(mapRegion.w / 2, mapRegion.h / 2),
					centerINew, centerJNew);
			// adjust offset
			this.offset.x += (centerINew - centerIOld) * 0.5 * this.tileDimensions.w;
			this.offset.y += (centerJNew - centerJOld) * 0.5 * this.tileDimensions.h;
		}


	public void setOffset(int x, int y) {
		this.offset.x = x;
		this.offset.y = y;
	}


	public void moveOffset(int x, int y) {
		this.offset.x += x * zoom;
		this.offset.y += y * zoom;
	}


	public SDL_Point *getOffset() {
		return this.offset;
	}


	/**
	 * get the rectangular region of the screen where the map is drawn
	 **/
	private SDL_Rect *getMapScreenRegion() {
		int windowWidth, windowHeight;
		SDL_GetWindowSize(this.window, &windowWidth, &windowHeight);
		
		SDL_Rect *region = new SDL_Rect(0, 0, windowWidth, windowHeight);

		return region;
	}


	public void render(SDL_Point *mousePosition) {
		if (this.renderer !is null && this.map !is null) {
			SDL_RenderClear(this.renderer);

			// get tiles section to draw per frame
			int iMin, iMax, jMin, jMax, windowWidth, windowHeight;
			SDL_Rect *mapRegion = this.getMapScreenRegion();
			this.getTileAtPixel(
					new SDL_Point(mapRegion.x, mapRegion.y), iMin, jMin);
			this.getTileAtPixel(
					new SDL_Point(mapRegion.w, mapRegion.h), iMax, jMax);
			iMin -= 1;
			jMin -= 1;
			iMax += 1;
			jMax += 1;
			iMin = min(max(iMin, 0), this.map.getWidth() - 1);
			jMin = min(max(jMin, 0), this.map.getHeight() - 1);
			iMax = max(min(iMax, this.map.getWidth() - 1), 0);
			jMax = max(min(jMax, this.map.getHeight() - 1), 0);

			for (uint i = iMin; i <= iMax; ++i) {
				for (uint j = jMin; j <= jMax; ++j) {
					int x, y;
					byte tile = this.map.getTile(i, j);

					SDL_Texture *texture;
					if (tile == 0) {
						texture = this.getTexture("grass");
					} else if (tile == 1) {
						texture = this.getTexture("water");
					}

					this.getTopLeftScreenCoordinate(
						i, j, x, y);
					this.drawTile(x, y, texture);
				}
			}

			// mouse marker
			int mouseI;
			int mouseJ;
			this.getTileAtPixel(mousePosition, mouseI, mouseJ);
			int x, y;
			this.getTopLeftScreenCoordinate(
					mouseI, mouseJ, x, y);
			this.drawTile(
					x, y,
					this.getTexture("border"));

			//Update the screen
			SDL_RenderPresent(this.renderer);
		}
	}
}
