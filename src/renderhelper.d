module renderhelper;

import client;
import color;
import constants;
import fontmanager;
import map;
import maprenderer;
import position;
import rect;
import textinput;
import texturemanager;
import utils;
import ui.mainmenu;
import ui.textinputrenderer;
import ui.ui;
import world.nation;
import world.nationprototype;
import world.structureprototype;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;

import std.conv;
import std.stdio;
import std.string;
import std.math;


static enum RendererState {
	MAIN_MENU,
	MAP,
	INPUT_POPUP,
	PAUSE_MENU};

/**
 * interface to the SDL rendering infrastructure
 **/
class RenderHelper {
	private UI ui;
	private MapRenderer mapRenderer;
	private MainMenu mainMenu;
	private TextInputRenderer textInputRenderer;

	private RendererState state;
	private RendererState lastState;

	private SDL_Renderer *renderer;
	private TextureManager textures;
	private FontManager fonts;
	private SDL_Window *window;
	private TextInput textInput;
	private Client client;

//DEBUGGING
	private string test;
//DEBUGGING END


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
		this.lastState = RendererState.MAIN_MENU;

		this.textures = new TextureManager(this.renderer);
		this.fonts = new FontManager();

		this.loadTexturesAndFonts();

		this.textInput = new TextInput();

		this.mainMenu = new MainMenu(this.client, this);
		this.textInputRenderer = new TextInputRenderer(this);

		//DEBUGGING
		this.textInputRenderer.setTextPointer(&(this.test));
		//DEBUGGING END

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
		this.textures.registerTexture("tile_0", "resources/img/grass.png");
		this.textures.registerTexture("tile_0_2", "resources/img/grass_2.png");
		this.textures.registerTexture("tile_1", "resources/img/water.png");
		this.textures.registerTexture("tile_1_2", "resources/img/water.png");
		this.textures.registerTexture("tile_2", "resources/img/mountain.png");
		this.textures.registerTexture("tile_2_2", "resources/img/mountain.png");
		this.textures.registerTexture("tile_3", "resources/img/trees.png");
		this.textures.registerTexture("tile_3_2", "resources/img/trees2.png");
		this.textures.registerTexture("mouseTile",
									  "resources/img/grid_border.png");
		this.textures.registerTexture("selectedTile",
									  "resources/img/grid_cursor.png");
		this.textures.registerTexture("border_top",
									  "resources/img/grid_border_top.png");
		this.textures.registerTexture("border_right",
									  "resources/img/grid_border_right.png");
		this.textures.registerTexture("border_bottom",
									  "resources/img/grid_border_bottom.png");
		this.textures.registerTexture("border_left",
									  "resources/img/grid_border_left.png");

		this.textures.registerTexture("ui_popup_background",
									  "resources/img/ui/mainmenu_button.png");

		this.textures.registerTexture("ui_background",
									  "resources/img/ui/ui_background.png");
		this.textures.registerTexture("button_default",
									  "resources/img/ui/button_default.png");
		this.textures.registerTexture("mainmenu_bg",
									  "resources/img/ui/mainmenu_bg.png");
		this.textures.registerTexture("mainmenu_button",
									  "resources/img/ui/mainmenu_button.png");
		this.textures.registerTexture("mainmenu_button_hover",
				"resources/img/ui/mainmenu_button_hover.png");
		this.textures.registerTexture("border_round_30",
									  "resources/img/ui/border_round_30.png");
		this.textures.registerTexture(NULL_TEXTURE,
									  "resources/img/ui/null.png");

		//TODO make portable
		this.fonts.registerFont(STD_FONT, "/usr/share/fonts/TTF/DejaVuSans.ttf");
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
						 prototype.getName());
			}
			bool success =
				this.textures.registerTexture(
						prototype.getFlagImageName(),
						prototype.getFlagImage());
		}
	}


	/**
	 * get the texture name for a corresponding tile identifier
	 **/
	public string getTextureNameByTileIdentifier(byte tile) {
		return "tile_" ~ text(tile);
	}


	/**
	 * get the size of a text rendered with a given font
	 *
	 * @return Rect r with
	 * 				r.w ... width
	 * 				r.h ... height
	 **/
	public Rect getTextSize(string text, string fontName) {
		return this.fonts.getTextSize(text, fontName);
	}


	/**
	 * get the selected position in the map rendering view
	 **/
	public Position getSelectedPosition() {
		if (this.mapRenderer is null) {
			return null;
		}
		return this.mapRenderer.getSelectedPosition();
	}


	/**
	 * get the tile dimensions as drawn by the map renderer without zooming
	 **/
	public const(Rect) getTileDimensions() const {
		if (this.mapRenderer is null) {
			return null;
		}
		return this.mapRenderer.getTileDimensions();
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


	public void setState(RendererState newState) {
		// save old state
		this.lastState = this.state;

		// main menu --> map
		if (this.state == RendererState.MAIN_MENU &&
				newState == RendererState.MAP) {
			this.loadGameTextures();
			this.ui = new UI(this.client, this);
			this.mapRenderer = new MapRenderer(this.client, this);
			this.state = state;
			this.notifyNationChanged();
		}
		// map --> main menu
		else if (this.state == RendererState.MAP &&
				newState == RendererState.MAIN_MENU) {
			this.ui = null;
			this.mapRenderer = null;
		}

		this.state = newState;
	}


	/**
	 * set state to the stored old state
	 **/
	public void restoreState() {
		this.setState(this.lastState);
	}


	public void drawText(const int x, const int y,
						 const(string) text,
						 const(string) fontName = STD_FONT,
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
	 * draw multiple lines of text
	 *
	 * @param x, y: top left position of first line of text
	 * @param text: string array of text lines
	 * @param fontName: identifier of font to use
	 * @param lineHeight: height of a line relative to font size
	 * 		a value of 1.0 means no space between consecutive lines
	 * @param color: color to draw in
	 **/
	public void drawTextMultiline(
			const int x, const int y,
			const(string[]) text,
			const(string) fontName = STD_FONT,
			const(double) lineHeight = 1.2,
			SDL_Color *color = null)
		in {
			TTF_Font *ttf = this.fonts.getFont(fontName);
			assert(ttf !is null, "Renderer::drawText: font is null");
		}
		body {
			if (color is null) {
				color = new SDL_Color(255, 255, 255);
			}
			int fontHeight = this.fonts.getFontHeight(fontName);

			for (int i = 0; i < text.length; ++i) {
				this.drawText(
						x, y + cast(int)(i * fontHeight * lineHeight),
						text[i], fontName, color);
			}
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
	 * draw a line with the given color to the renderer
	 **/
	public void drawLine(int x1, int y1, int x2, int y2, const(Color) color) {
		SDL_SetRenderDrawBlendMode(this.renderer, SDL_BLENDMODE_BLEND);
		SDL_SetRenderDrawColor(this.renderer,
							   color.r, color.g, color.b, color.a);
		SDL_RenderDrawLine(this.renderer, x1, y1, x2, y2);
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
		this.textInputRenderer.setScreenRegion(
				200, 100, windowWidth - 400, windowHeight - 200);
	}


	public void handleEvent(SDL_Event event) {
		if (this.state == RendererState.MAP) {
			this.mapRenderer.handleEvent(event);
			this.ui.handleEvent(event);
		} else if (this.state == RendererState.MAIN_MENU) {
			this.mainMenu.handleEvent(event);
		} else if (this.state == RendererState.INPUT_POPUP) {
			this.textInputRenderer.handleEvent(event);
		}

		this.textInput.handleEvent(event);
	}


	public void render() {
		this.updateScreenRegions();

		SDL_SetRenderDrawColor(this.renderer, 0, 0, 0, 255);	// set black
		SDL_RenderClear(this.renderer);

		if (this.state == RendererState.MAP) {
			this.mapRenderer.render();
			this.ui.render();
		} else if (this.state == RendererState.MAIN_MENU) {
			this.mainMenu.render();
		} else if (this.state == RendererState.INPUT_POPUP) {
			this.textInputRenderer.render();
		}

		// update screen
		SDL_RenderPresent(this.renderer);
	}

	/**
	 * method is called if active nation changes
	 **/
	public void notifyNationChanged() {
		if (this.state == RendererState.MAP) {
			const(Nation) currentNation = this.client.getCurrentNation();
			this.mapRenderer.panToTile(currentNation.getSeat().getPosition());
		}
	}
}
