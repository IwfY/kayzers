module renderhelper;

import color;
import constants;
import fontmanager;
import rect;
import textinput;
import texturemanager;
import utils;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;

import std.conv;
import std.stdio;
import std.string;
import std.math;

/**
 * interface to the SDL rendering infrastructure
 **/
class RenderHelper {
	private SDL_Renderer *renderer;
	private TextureManager textures;
	private FontManager fonts;
	private SDL_Window *window;
	private TextInput textInput;

//DEBUGGING
	private string test;
//DEBUGGING END


	public this(SDL_Window *window) {
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

		this.textInput = new TextInput();
		
		this.textInputRenderer = new TextInputRenderer(this);

		//DEBUGGING
		this.textInputRenderer.setTextPointer(&(this.test));
		//DEBUGGING END
	}


	public ~this() {
		delete this.textures;
		delete this.fonts;
		SDL_DestroyRenderer(this.renderer);
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
	public Rect getScreenRegion() {
		int windowWidth, windowHeight;
		SDL_GetWindowSize(this.window, &windowWidth, &windowHeight);

		Rect region = new Rect(0, 0, windowWidth, windowHeight);

		return region;
	}


	public TextInput getTextInputServer() {
		return this.textInput;
	}
}
