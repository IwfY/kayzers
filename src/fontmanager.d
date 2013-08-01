module fontmanager;

import derelict.sdl2.ttf;

import std.stdio;
import std.string;


class Font {
	public TTF_Font *font;
	
	public this(TTF_Font *font) {
		this.font = font;
	}
	
	public ~this() {
		TTF_CloseFont(this.font);
	}
}

class FontManager {
	private Font[string] fonts;
	
	public ~this() {
		// destroy fonts
		string[] keys = this.fonts.keys;
		for(int i = 0; i < keys.length; ++i) {
			string key = keys[i];
			Font font = this.fonts[key];
			delete font;
			this.fonts.remove(key);
		}
	}
	
	/**
	 * load a font from a file and make it accessible through the font map
	 *
	 * @param fontName key to the font map
	 * @param filename path to the font to load
	 **/
	public bool registerFont(const string fontName,
							 const string filename) {
		
		TTF_Font *ttf = TTF_OpenFont(toStringz(filename), 12);
		if (ttf is null) {
			return false;
		}
		Font font = new Font(ttf);		
		this.fonts[fontName] = font;
		
		return true;
	}


	public TTF_Font *getFont(const string fontName) {
		return this.fonts[fontName].font;
	}
}
