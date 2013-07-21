module renderer;

import map;

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
	public void loadMap(string filename) {
		this.map = new Map(filename);
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
			writefln("%d, %d, %d, %d", position.x, position.y, position.w, position.h);
		}

		SDL_RenderCopy(this.renderer, texture, null, &position);
	}

	private void drawTile(int x, int y, SDL_Texture *texture) {
		SDL_Rect position;
		position.x = x;
		position.y = y;

		position.w = cast(int)(ceil(cast(double)this.tileDimensions.w / cast(double)this.zoom));
		position.h = cast(int)(ceil(cast(double)this.tileDimensions.h / cast(double)this.zoom));

		SDL_RenderCopy(this.renderer, texture, null, &position);
	}


	private void getTileAtPixel(SDL_Point *mousePosition,
								out int i, out int j) {
		i = cast(int)((mousePosition.y - this.offset.y)
				* 2 / this.tileDimensions.h);
		j = cast(int)(((mousePosition.x - this.offset.x)
				+ cast(int)(i * 0.5 * this.tileDimensions.w)) / this.tileDimensions.w);

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

		x = cast(int)(this.offset.x + j * tileWidth -
				i * 0.5 * tileWidth);
		y = cast(int)(this.offset.y + i * 0.5 * tileHeight);

		debug(3) {
			writefln("Renderer::getTopLeftScreenCoordinate i: %d, j: %d --> x: %d, y:%d",
					 i, j, x, y);
		}
	}


	public void setZoom(int zoom)
		in {
			assert(zoom >= 1 && zoom <= 4);
		}
		body {
			this.zoom = zoom;
		}


	public void setOffset(int x, int y) {
		this.offset.x = x;
		this.offset.y = y;
	}


	public void moveOffset(int x, int y) {
		this.offset.x += x;
		this.offset.y += y;
	}


	public SDL_Point *getOffset() {
		return this.offset;
	}


	public void render(SDL_Point *mousePosition) {
		if (this.renderer !is null && this.map !is null) {
			SDL_RenderClear(this.renderer);

			for (uint i = 0; i < this.map.getWidth(); ++i) {
				for (uint j = 0; j < this.map.getHeight(); ++j) {
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
