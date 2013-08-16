module renderhelper;

import client;
import fontmanager;
import map;
import maprenderer;
import position;
import rect;
import textinput;
import texturemanager;
import utils;
import ui.mainmenu;
import ui.ui;
import world.nationprototype;
import world.structureprototype;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;

import std.stdio;
import std.string;
import std.math;


static enum RendererState {MAIN_MENU, MAP, PAUSE_MENU};

/**
 * interface to the SDL rendering infrastructure
 **/
class RenderHelper {
	private UI ui;
	private MapRenderer mapRenderer;
	private MainMenu mainMenu;

	private RendererState state;

	private SDL_Renderer *renderer;
	private TextureManager textures;
	private FontManager fonts;
	private SDL_Window *window;
	private TextInput textInput;
	private Client client;



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

		this.state = RendererState.MAIN_MENU;

		this.textures = new TextureManager(this.renderer);
		this.fonts = new FontManager();

		this.loadTexturesAndFonts();

		this.textInput = new TextInput();

		this.mainMenu = new MainMenu(this.client, this);



		this.updateScreenRegions();
	}


	public ~this() {
		delete this.textures;
		delete this.fonts;
		SDL_DestroyRenderer(this.renderer);
	}



	public void loadTexturesAndFonts() {
		//TODO declare general resources in a file
		this.textures.registerTexture("grass", "resources/img/grass.png");
		this.textures.registerTexture("water", "resources/img/water.png");
		this.textures.registerTexture("border",
									  "resources/img/grid_border.png");
		this.textures.registerTexture("cursor",
									  "resources/img/grid_cursor.png");
		this.textures.registerTexture("ui_background",
									  "resources/img/ui/ui_background.png");
		this.textures.registerTexture("button_default",
									  "resources/img/ui/button_default.png");
		this.textures.registerTexture("mainmenu_bg",
									  "resources/img/ui/mainmenu_bg.png");
		this.textures.registerTexture("mainmenu_button",
									  "resources/img/ui/mainmenu_button.png");
		this.textures.registerTexture("border_round_30",
									  "resources/img/ui/border_round_30.png");
		this.textures.registerTexture("null",
									  "resources/img/ui/null.png");

		//TODO make portable
		this.fonts.registerFont("std", "/usr/share/fonts/TTF/DejaVuSans.ttf");
		this.fonts.registerFont("mainMenuHead",
								"/usr/share/fonts/TTF/DejaVuSans.ttf",
								80);
	}


	/**
	 * load all textures that are specific to the started game
	 **/
	public void loadGameTextures() {
		// load textures for structures
		foreach (const StructurePrototype structurePrototype;
				 this.client.getStructurePrototypes()) {
			debug(2) {
				writefln("load texture(s) for structure %s",
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

		// load textures for nations
		foreach (const(NationPrototype) prototype;
				 this.client.getNationPrototypes()) {
			debug(2) {
				writefln("load texture(s) for nation %s",
						 nationPrototype.getName());
			}
			bool success =
				this.textures.registerTexture(
						prototype.getFlagImageName(),
						prototype.getFlagImage());
		}
	}


	public Rect getTextSize(string text, string fontName) {
		return this.fonts.getTextSize(text, fontName);
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


	public void setState(RendererState state) {
		// main menu --> map
		if (this.state == RendererState.MAIN_MENU &&
				state == RendererState.MAP) {
			this.loadGameTextures();
			this.ui = new UI(this.client, this);
			this.mapRenderer = new MapRenderer(this.client, this);
		}
		// map --> main menu
		else if (this.state == RendererState.MAP &&
				state == RendererState.MAIN_MENU) {
			this.ui = null;
			this.mapRenderer = null;
		}
		this.state = state;
	}


	public void drawText(const int x, const int y,
						 const(string) text,
						 const(string) fontName = "std",
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
			SDL_Surface *surface = TTF_RenderUTF8_Blended(
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

	public void drawTexture(int x, int y, int w, int h,
						    const string textureName) {
		SDL_Rect *position = new SDL_Rect();
		position.x = x;
		position.y = y;
		position.w = w;
		position.h = h;
		SDL_Texture *texture = this.textures.getTexture(textureName);
		this.drawTexture(position, texture);
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
	 * get the rectangular region of the screen
	 **/
	public SDL_Rect *getScreenRegion() {
		int windowWidth, windowHeight;
		SDL_GetWindowSize(this.window, &windowWidth, &windowHeight);

		SDL_Rect *region = new SDL_Rect(0, 0, windowWidth, windowHeight);

		return region;
	}


	public TextInput getTextInputServer() {
		return this.textInput;
	}


	public void updateScreenRegions() {
		int windowWidth, windowHeight;
		SDL_GetWindowSize(this.window, &windowWidth, &windowHeight);
		if (this.state == RendererState.MAP) {
			this.mapRenderer.setScreenRegion(0, 0,
											 windowWidth, windowHeight - 180);
			this.ui.setScreenRegion(0, windowHeight - 180, windowWidth, 180);
		}
		this.mainMenu.setScreenRegion(0, 0, windowWidth, windowHeight);
	}


	public void handleEvent(SDL_Event event) {
		if (this.state == RendererState.MAP) {
			this.mapRenderer.handleEvent(event);
			this.ui.handleEvent(event);
		} else if (this.state == RendererState.MAIN_MENU) {
			this.mainMenu.handleEvent(event);
		}

		this.textInput.handleEvent(event);
	}


	public void render() {
		this.updateScreenRegions();
		SDL_RenderClear(this.renderer);

		if (this.state == RendererState.MAP) {
			this.mapRenderer.render();
			this.ui.render();
		} else if (this.state == RendererState.MAIN_MENU) {
			this.mainMenu.render();
		}

		// update screen
		SDL_RenderPresent(this.renderer);
	}
}
