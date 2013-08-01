module renderer;

import map;
import ui;
import texturemanager;
import fontmanager;
import utils;
import client;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;

import std.stdio;
import std.string;
import std.math;


class Renderer {
	private Map map;
	private UI ui;
	private SDL_Renderer *renderer;
	private TextureManager textures;
	private FontManager fonts;
	private SDL_Window *window;
	private SDL_Rect *tileDimensions;
	private Client client;

	// offset is added to the tile position when drawing
	private SDL_Point *offset;
	private int zoom;


	public this(Client client, SDL_Window *window) {
		this.client = client;
		this.window = window;

		this.renderer = SDL_CreateRenderer(
				this.window,
				-1,
				SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
		if (this.renderer is null) {
			writeln(SDL_GetError());
		}

		this.textures = new TextureManager(this.renderer);
		this.fonts = new FontManager();

		this.ui = new UI(this.client, this);

		this.offset = new SDL_Point(0, 0);
		this.tileDimensions = new SDL_Rect(0, 0);
		this.tileDimensions.w = 120;
		this.tileDimensions.h = 70;
		this.zoom = 1;
	}


	public ~this() {
		delete this.textures;
		delete this.fonts;
		SDL_DestroyRenderer(this.renderer);
	}

	/**
	 * load a texture from a file and make it accessible through the texture
	 * manager
	 *
	 * @param textureName key to the texture manager
	 * @param filename path to the texture to load
	 **/
	public bool registerTexture(const string textureName,
							    const string filename) {
		return this.textures.registerTexture(textureName, filename);
	}


	/**
	 * load a font from a file and make it accessible through the font manager
	 *
	 * @param fontName key to the font manager
	 * @param filename path to the font to load
	 **/
	public bool registerFont(const string fontName,
							 const string filename) {
		return this.fonts.registerFont(fontName, filename);
	 }


	/**
	 * pan the map center to the given tile coordinate
	 **/
	public void panToTile(int i, int j) {
		int centerIOld, centerJOld;
		SDL_Rect *mapRegion = this.getMapScreenRegion();
		this.getTileAtPixel(
				new SDL_Point(mapRegion.w / 2, mapRegion.h / 2),
				centerIOld, centerJOld);
		// adjust offset
		this.offset.x += (centerIOld - i) * 0.5 * this.tileDimensions.w;
		this.offset.y += (centerJOld - j) * 0.5 * this.tileDimensions.h;
	}


	/**
	 * load an image file representing the map and prerender the map to
	 * a surface
	 **/
	public void setMap(Map map) {
		this.map = map;
	}


	public void drawText(const int x, const int y,
						 const string text,
						 const string fontName = "std",
						 SDL_Color *color = null)
		in {
			TTF_Font *ttf = this.fonts.getFont(fontName);
			assert(ttf !is null, "Renderer::drawText: font is null");
		}
		body {
			if (color is null) {
				color = new SDL_Color(255, 255, 255);
			}
			TTF_Font *ttf = this.fonts.getFont(fontName);
			SDL_Surface *surface = TTF_RenderText_Blended(
					ttf, toStringz(text), *color);
			SDL_Texture *texture = SDL_CreateTextureFromSurface(
					this.renderer, surface);
			this.drawTexture(x, y, texture);

			SDL_FreeSurface(surface);
			SDL_DestroyTexture(texture);
		}


	/**
	 * draw a named texture to the renderer
	 **/
	public void drawTexture(const int x, const int y,
						    const string textureName) {
		SDL_Texture *texture = this.textures.getTexture(textureName);
		this.drawTexture(x, y, texture);
	}


	/**
	 * draw a texture to the renderer
	 **/
	public void drawTexture(const int x, const int y,
							SDL_Texture *texture) {
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


	private void drawTileIJ(int i, int j, SDL_Texture *texture) {
		SDL_Rect *position = new SDL_Rect();
		this.getTopLeftScreenCoordinate(i, j, position.x, position.y);

		position.w = cast(int)(
			ceil(cast(double)this.tileDimensions.w / cast(double)this.zoom));
		position.h = cast(int)(
			ceil(cast(double)this.tileDimensions.h / cast(double)this.zoom));

		SDL_RenderCopy(this.renderer, texture, null, position);
	}


	/**
	 * get the tile coordinate for a given screen position
	 *
	 * TODO: distance function could be weighted depending on tile
	 * 		 dimension
	 **/
	public void getTileAtPixel(SDL_Point *position,
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
	public SDL_Rect *getMapScreenRegion() {
		int windowWidth, windowHeight;
		SDL_GetWindowSize(this.window, &windowWidth, &windowHeight);

		SDL_Rect *region = new SDL_Rect(0, 0, windowWidth, windowHeight - 150);

		return region;
	}


	public void render(SDL_Point *mousePosition,
					   SDL_Rect *selectedRegion) {
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
						texture = this.textures.getTexture("grass");
					} else if (tile == 1) {
						texture = this.textures.getTexture("water");
					}

					this.drawTileIJ(i, j, texture);
				}
			}

			// selected region
			this.drawTileIJ(
					selectedRegion.x, selectedRegion.y,
					this.textures.getTexture("cursor"));

			// mouse marker
			int mouseI;
			int mouseJ;
			this.getTileAtPixel(mousePosition, mouseI, mouseJ);
			this.drawTileIJ(
					mouseI, mouseJ,
					this.textures.getTexture("border"));

			this.ui.render(mousePosition, selectedRegion);
			//Update the screen
			SDL_RenderPresent(this.renderer);
		}
	}
}
