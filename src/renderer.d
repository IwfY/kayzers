module renderer;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.stdio;
import std.string;

class Renderer {
	private SDL_Surface *map;
	private SDL_Renderer *renderer;
	private SDL_Texture*[string] textures;
	private SDL_Window *window;
	
	
	public this(SDL_Window *window) {
		this.window = window;
		
		this.renderer = SDL_CreateRenderer(
				this.window,
				-1,
				SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
		if (this.renderer is null) {
			writeln(SDL_GetError());
		}
	}
	
	
	public ~this() {
		SDL_DestroyRenderer(this.renderer);
		if (this.map !is null) {
			SDL_FreeSurface(this.map);
		}
		
		// destroy textures
		string[] keys = this.textures.keys;
		for (int i = 0; i < keys.length; ++i) {
			SDL_DestroyTexture(this.textures[keys[i]]);
			this.textures.remove(keys[i]);
		}
	}
	
	
	/**
	 * load an image file representing the map
	 **/
	public bool loadMap(string filename) {
		this.map = IMG_Load(toStringz(filename));
		if (this.map is null) {
			return false;
		}
		
		return true;
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
		
		SDL_Texture *tex;
		tex = IMG_LoadTexture(this.renderer, toStringz(filename));
		if (tex is null) {
			return false;
		}
		
		this.textures[textureName] = tex;
		
		debug(2) {
			writeln("Renderer::registerTexture Load %s as %s",
					filename, textureName);
		}
		
		return true;
	}
	
	
	public SDL_Texture *getTexture(const string textureName) {
		// TODO: check if texture available
		return this.textures[textureName];
	}
	
	/**
	 * draw a texture to the renderer
	 **/
	private void drawTexture(int x, int y, SDL_Texture *texture) {
		SDL_Rect position;
		position.x = x;
		position.y = y;
		// get width and height of texture
		SDL_QueryTexture(texture, null, null, &position.w, &position.h);
		
		SDL_RenderCopy(this.renderer, texture, null, &position);
	}
	
	
	public void render(SDL_Rect *offset) {
		if (this.renderer !is null && this.map !is null) {
			SDL_RenderClear(this.renderer);
	
			SDL_LockSurface(this.map);
			
			int tileWidth = 72;
			int tileHeight = 34;
			int mapWidth = this.map.w;
			int mapHeight = this.map.h;
			void *pixelPointer = this.map.pixels;
			for(int i = 0; i < mapHeight; ++i) {
				for (int j = 0; j < mapWidth; ++j) {
					if (*cast(byte*)(pixelPointer) == 0) {
						this.drawTexture(
							offset.x + j * tileWidth - 
								cast(int)(i * 0.5 * tileWidth),
							offset.y + cast(int)(i * 0.5 * tileHeight),
							this.getTexture("grass"));
					} else {
						this.drawTexture(
							offset.x + j * tileWidth - 
								cast(int)(i * 0.5 * tileWidth),
							offset.y + cast(int)(i * 0.5 * tileHeight),
							this.getTexture("water"));
					}
					pixelPointer += 4;
				}
			}
			
			SDL_UnlockSurface(this.map);
			
			//Update the screen
			SDL_RenderPresent(this.renderer);
		}
	}
}