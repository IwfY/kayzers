module ui.texturemanager;

import color;
import ui.texture;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.stdio;
import std.string;


class TextureManager {
	private Texture[string] textures;
	private SDL_Renderer *renderer;

	public this(SDL_Renderer *renderer) {
		this.renderer = renderer;
	}

	public ~this() {
		// destroy textures
		string[] keys = this.textures.keys;
		for(int i = 0; i < keys.length; ++i) {
			string key = keys[i];
			Texture tex = this.textures[key];
			delete tex;
			this.textures.remove(key);
		}
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

		SDL_Surface *surface = IMG_Load(toStringz(filename));
		if (surface is null) {
			return false;
		}
		SDL_Texture *texture = SDL_CreateTextureFromSurface(this.renderer,
															surface);
		if (texture is null) {
			return false;
		}

		Texture tex = new StaticTexture(surface, texture);
		this.setTexture(textureName, tex);

		debug(2) {
			writefln("Renderer::registerTexture Load %s as %s",
					filename, textureName);
		}

		return true;
	}


	public bool registerTexture(const(string) textureName,
								const(string[]) filenames,
								const(uint[]) durations)
		in {
			assert(filenames.length == durations.length,
				   "TextureManager::registerTexture array length missmatch");
		}
		body {
			StaticTexture[] textures;

			foreach (string filename; filenames) {
				SDL_Surface *surface = IMG_Load(toStringz(filename));
				if (surface is null) {
					return false;
				}
				SDL_Texture *texture =
						SDL_CreateTextureFromSurface(this.renderer,
													 surface);
				if (texture is null) {
					return false;
				}

				StaticTexture tex = new StaticTexture(surface, texture);
				textures ~= tex;

			}

			Texture tex = new AnimatedTexture(textures, durations);
			this.setTexture(textureName, tex);

			return true;
		}


	public bool registerTexture(const(string) textureName,
								SDL_Texture* texture) {
		Texture tmp = new StaticTexture(null, texture);
		this.setTexture(textureName, tmp);

		return true;
	}


	/**
	 * create and register a texture from a template
	 * grayscale of template indicates transparency of target (white means opaque)
	 * color the texture with the given color
	 **/
	public bool registerColoredTexture(const(string) templateTextureName,
	                                   const(string) targetTextureName,
	                                   const(Color) color) {
		Texture templateTexture = this.textures.get(templateTextureName, null);
		if (templateTexture is null) {
			return false;
		}
		SDL_Surface* templateSurface = templateTexture.getSurface();

		SDL_Surface* newSurface = SDL_CreateRGBSurface(
			templateSurface.flags,
			templateSurface.w,
			templateSurface.h,
			32,
			templateSurface.format.Rmask,
			templateSurface.format.Gmask,
			templateSurface.format.Bmask,
			templateSurface.format.Amask);

		ubyte r, g, b, a;
		for (int i = 0; i < templateSurface.w; ++i) {
			for (int j = 0; j < templateSurface.h; ++j) {
				TextureManager.getSurfacePixel(templateSurface,
											   i, j,
				                               r, g, b, a);
				// for simplicity I use the red value as alpha indicator
				TextureManager.putSurfacePixel(newSurface,
				                               i, j,
				                               color.r, color.g, color.b, r);
			}
		}

		SDL_Texture* texture = SDL_CreateTextureFromSurface(this.renderer, newSurface);

		Texture newTexture = new StaticTexture(newSurface, texture);
		this.setTexture(targetTextureName, newTexture);

		return true;
	}


	private void setTexture(string textureName, Texture texture) {
		// delete old texture if present
		Texture oldTexture = this.textures.get(textureName, null);
		if (oldTexture !is null) {
			delete oldTexture;
		}
		this.textures[textureName] = texture;
	}


	public SDL_Texture *getTexture(const string textureName) {
		Texture texture = this.textures.get(textureName, null);
		assert (texture !is null,
				"TextureManager::getTexture texture not found");

		return texture.getTexture();
	}

	public SDL_Texture *getTexture(const string textureName, int tick) {
		Texture texture = this.textures.get(textureName, null);
		assert (texture !is null,
				"TextureManager::getTexture texture not found");

		return texture.getTexture(tick);
	}

	public SDL_Surface *getSurface(const string textureName) {
		Texture texture = this.textures.get(textureName, null);
		assert (texture !is null,
				"TextureManager::getSurface texture not found");
		return texture.getSurface();
	}


	/**
	 * get the pixel color values from a SDL_Surface
	 **/
	public static void getSurfacePixel(
		SDL_Surface *surface, int x, int y,
		out ubyte r, out ubyte g, out ubyte b, out ubyte a)
	in {
		assert(surface.format.BytesPerPixel == 4);
		assert(x >= 0 && y >= 0);
		assert(x < surface.w && y < surface.h);
	}
	body {
		uint *pixels = cast(uint *)surface.pixels;
		uint pixel = pixels[(y * surface.w) + x];

		a = cast(ubyte)(pixel >> 24);
		b = cast(ubyte)(pixel >> 16);
		g = cast(ubyte)(pixel >> 8);
		r = cast(ubyte)pixel;
	}


	/**
	 * put given color to the surface at the given position
	 **/
	public static void putSurfacePixel(
		SDL_Surface *surface, int x, int y,
		ubyte r, ubyte g, ubyte b, ubyte a)
	in {
		assert(surface.format.BytesPerPixel == 4);
		assert(x >= 0 && y >= 0);
		assert(x < surface.w && y < surface.h);
	}
	body {
		uint *pixels = cast(uint *)surface.pixels;
		uint color = (a << 24) + (b << 16) + (g << 8) + r;

		// lock surface
		if(SDL_MUSTLOCK(surface)) {
			SDL_LockSurface(surface);
		}

		// put pixel data
		pixels[(y * surface.w) + x] = color;

		// unlock surface
		if(SDL_MUSTLOCK(surface)) {
			SDL_UnlockSurface(surface);
		}
	}
}
