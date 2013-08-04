module renderhelper;

import map;
import ui.ui;
import maprenderer;
import texturemanager;
import fontmanager;
import utils;
import client;
import position;
import world.structureprototype;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;

import std.stdio;
import std.string;
import std.math;


class RenderHelper {
	private Map map;
	private UI ui;
	private MapRenderer mapRenderer;
	private SDL_Renderer *renderer;
	private TextureManager textures;
	private FontManager fonts;
	private SDL_Window *window;
	private Client client;


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
		
		this.loadTexturesAndFonts();

		this.ui = new UI(this.client, this);
		this.mapRenderer = new MapRenderer(this.client, this, this.map);

		this.updateScreenRegions();
	}


	public ~this() {
		delete this.textures;
		delete this.fonts;
		SDL_DestroyRenderer(this.renderer);
	}
	
	
	
	public void loadTexturesAndFonts() {
		this.textures.registerTexture("grass", "resources/img/grass_n.png");
		this.textures.registerTexture("water", "resources/img/water_n.png");
		this.textures.registerTexture("border",
									  "resources/img/grid_border.png");
		this.textures.registerTexture("cursor",
									  "resources/img/grid_cursor.png");
		this.textures.registerTexture("ui_background",
									  "resources/img/ui_background.png");
		this.textures.registerTexture("button_default",
									  "resources/img/ui/button_default.png");
		// load textures for structures
		foreach (const StructurePrototype structurePrototype;
				 this.client.getStructurePrototypes()) {
			debug(2) {
				writefln("load texture for structure %s",
						 structurePrototype.getName());
			}
			bool success =
				this.textures.registerTexture(
						structurePrototype.getIconImageName(),
						structurePrototype.getIconImage());
			success =
				this.textures.registerTexture(
					structurePrototype.getTileImageName(),
					structurePrototype.getTileImage());
		}
		
		//TODO make portable
		this.fonts.registerFont("std", "/usr/share/fonts/TTF/DejaVuSans.ttf");
	}


	public Position getSelectedPosition() {
		return this.mapRenderer.getSelectedPosition();
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


	public void drawTexture(SDL_Rect *dest, string textureName) {
		SDL_Texture *texture = this.textures.getTexture(textureName);
		this.drawTexture(dest, texture);
	}


	public void drawTexture(SDL_Rect *dest, SDL_Texture *texture) {
		debug(2) {
			writefln("Renderer::drawTexture %d, %d, %d, %d",
					 dest.x, dest.y, dest.w, dest.h);
		}

		SDL_RenderCopy(this.renderer, texture, null, dest);
	}


	/**
	 * draw a texture to the renderer
	 **/
	public void drawTexture(const int x, const int y,
							SDL_Texture *texture) {
		SDL_Rect *position = new SDL_Rect();
		position.x = x;
		position.y = y;

		SDL_QueryTexture(texture, null, null, &position.w, &position.h);

		this.drawTexture(position, texture);
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


	public void updateScreenRegions() {
		int windowWidth, windowHeight;
		SDL_GetWindowSize(this.window, &windowWidth, &windowHeight);
		this.mapRenderer.setScreenRegion(0, 0, windowWidth, windowHeight - 150);
		this.ui.setScreenRegion(0, windowHeight - 150, windowWidth, 150);
	}


	public void handleEvent(SDL_Event event) {
		this.mapRenderer.handleEvent(event);
		this.ui.handleEvent(event);
	}


	public void render() {
		this.updateScreenRegions();
		SDL_RenderClear(this.renderer);

		this.mapRenderer.render();
		this.ui.render();

		// update screen
		SDL_RenderPresent(this.renderer);
	}
}
