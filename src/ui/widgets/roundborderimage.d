module ui.widgets.roundborderimage;

import ui.renderhelper;
import ui.widgets.widget;

import derelict.sdl2.sdl;

/**
 * an image with a round border
 *
 * the image to be bordered is given as the texture and has to be 28x28 pixel
 **/
class RoundBorderImage : Widget {
	private string textureName;

	public this(RenderHelper renderer,
				string textureName,
				const(SDL_Rect *)bounds = new SDL_Rect()) {
		super(renderer, bounds);
		this.textureName = textureName;

		// width and height are fixed
		this.bounds.w = 30;
		this.bounds.h = 30;
	}


	public override void setBounds(int x, int y, int w, int h) {
		this.bounds.x = x;
		this.bounds.y = y;
		this.bounds.w = 30;
		this.bounds.h = 30;
	}


	public void setTextureName(string textureName) {
		this.textureName = textureName;
	}


	protected override void draw() {
		SDL_Rect* bgBounds = new SDL_Rect(
			this.bounds.x + 1, this.bounds.y + 1, 28, 28);

		this.renderer.drawTexture(bgBounds, this.textureName);
		this.renderer.drawTexture(this.bounds, "border_round_30");
	}
}
