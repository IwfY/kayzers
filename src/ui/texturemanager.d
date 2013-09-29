module ui.texturemanager;

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
}
