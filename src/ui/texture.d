module ui.texture;

import derelict.sdl2.sdl;

interface Texture {
	public SDL_Texture *getTexture();
	public SDL_Texture *getTexture(int tick);
	public SDL_Surface *getSurface();
}


class StaticTexture : Texture {
	private SDL_Surface *surface;
	private SDL_Texture *texture;

	public this(SDL_Surface *surface, SDL_Texture *texture) {
		this.surface = surface;
		this.texture = texture;
	}

	public ~this() {
		SDL_DestroyTexture(this.texture);
		SDL_FreeSurface(this.surface);
	}

	public SDL_Texture *getTexture() {
		return this.texture;
	}

	public SDL_Texture *getTexture(int tick) {
		return this.getTexture();
	}

	public SDL_Surface *getSurface() {
		return this.surface;
	}
}


class AnimatedTexture : Texture {
	private StaticTexture[] textures;
	private uint[] startTimes;
	private uint[] endTimes;
	private uint animationLength;

	public this(StaticTexture[] textures, const(uint[]) durations)
		in {
			assert(textures.length == durations.length,
				   "AnimatedTexture::this array length missmatch");
		}
		body {
			this.textures = textures;

			// calculate start times
			this.animationLength = 0;
			foreach (uint duration; durations) {
				this.startTimes ~= this.animationLength;
				this.animationLength += duration;
				this.endTimes ~= this.animationLength - 1;
			}
	}

	public ~this() {
		foreach (Texture texture; this.textures) {
			delete texture;
		}
	}

	public SDL_Texture *getTexture() {
		return this.textures[0].getTexture();
	}

	public SDL_Texture *getTexture(int tick) {
		int tickModulo = tick % this.animationLength;
		for (int i = 0; i < this.endTimes.length; ++i) {
			if (tickModulo <= this.endTimes[i]) {
				return this.textures[i].getTexture();
			}
		}

		assert(false, "AnimatedTexture::getTexture texture not found");
	}

	public SDL_Surface *getSurface() {
		return this.textures[0].getSurface();
	}
}
