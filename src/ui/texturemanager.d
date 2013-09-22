module ui.texturemanager;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.stdio;
import std.string;


class Texture {
	public SDL_Surface *surface;
	public SDL_Texture *texture;
	
	public this(SDL_Surface *surface, SDL_Texture *texture) {
		this.surface = surface;
		this.texture = texture;
	}
	
	public ~this() {
		SDL_DestroyTexture(this.texture);
		SDL_FreeSurface(this.surface);
	}
}

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

		Texture tex = new Texture(surface, texture);
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
}
