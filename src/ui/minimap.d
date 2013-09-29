module ui.minimap;

//import color;
import map;
import rect;
import ui.renderhelper;
import ui.widget;

import derelict.sdl2.sdl;

import std.conv;
import std.math;

class MiniMap : Widget {
	private const(Map) map;
	private int tileWidth;
	private int tileHeight;
	private int offsetX;
	private int textureWidth;
	private int textureHeight;

	public this(RenderHelper renderer,
				string name,
				string textureName,
				const(SDL_Rect *)bounds,
				const(Map) map) {
		super(renderer, name, textureName, bounds);

		this.map = map;

		this.tileWidth = 2;
		this.tileHeight = 2;
		this.offsetX = cast(int)(this.map.getWidth() * tileWidth * 0.5);

		this.textureWidth = this.tileWidth * this.map.getWidth() + 4;
		this.textureHeight = this.tileHeight * this.map.getHeight() + 4;

		this.updateMap();
	}


	private void drawTileIJ(int i, int j, string textureName) {
		int offsetY = 0;
		SDL_Rect *position = new SDL_Rect();

		position.x = 2 + cast(int)(round(
				this.offsetX + i * 0.5 * this.tileWidth
							 - j * 0.5 * this.tileWidth));
		position.y = 2 + cast(int)(round(
				offsetY + j * 0.5 * this.tileHeight
						+ i * 0.5 * this.tileHeight));

		position.w = this.tileWidth;
		position.h = this.tileHeight;

		this.renderer.drawTexture(position, textureName);
	}


	private void updateMap() {
		// create a texture to render map to
		this.renderer.setRenderTargetTexture(
				"minimap", this.textureWidth, this.textureHeight);

		this.renderer.drawTexture(0, 0, textureWidth, textureHeight,
								  this.textureName);

		// render tiles
		for (uint i = 0; i < this.map.getWidth(); ++i) {
			for (uint j = 0; j < this.map.getHeight(); ++j) {
				byte tile = this.map.getTile(i, j);
				string textureName = "tile_" ~ text(tile);
				this.drawTileIJ(i, j, textureName);
			}
		}

		this.renderer.resetRenderTarget();
	}


	public override void draw() {
		this.renderer.drawTexture(this.bounds, "minimap");
	}
}
