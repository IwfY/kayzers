module renderhelper;

import map;
import ui.ui;
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


class RenderHelper {
	private Map map;
	private UI ui;
	private SDL_Renderer *renderer;
	private TextureManager textures;
	private FontManager fonts;
	private SDL_Window *window;
	private SDL_Rect *tileDimensions;
	private Client client;
	private SDL_Rect *selectedRegion;

	// offset is added to the tile position when drawing
	private SDL_Point *offset;
	private int zoom;


	public this(Client client, SDL_Window *window, Map map) {
		this.client = client;
		this.window = window;
		this.map = map;

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
		this.selectedRegion = new SDL_Rect();

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
	
	
	public void uiCallbackHandler(string name) {
		writefln("Renderer::uiCallbackHandler %s", name);
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


	/**
	 * get the rectangular region of the screen where the map is drawn
	 **/
	public SDL_Rect *getMapScreenRegion() {
		int windowWidth, windowHeight;
		SDL_GetWindowSize(this.window, &windowWidth, &windowHeight);

		SDL_Rect *region = new SDL_Rect(0, 0, windowWidth, windowHeight - 150);

		return region;
	}
	
	
	public void render() {
		
	}
}
