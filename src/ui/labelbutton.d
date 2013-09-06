module ui.labelbutton;

import renderhelper;
import ui.button;
import ui.label;
import ui.hoverwidget;

import derelict.sdl2.sdl;

class LabelButton : HoverWidget {
	private Button button;
	private Label label;

	public this(RenderHelper renderer,
				string name,
				string textureName,
				string hoverTextureName,
				SDL_Rect *bounds,
				void delegate(string) callback,
				string text,
				string fontName,
				SDL_Color *color = null) {
		super(renderer, name, textureName, hoverTextureName, bounds);
		this.button = new Button(this.renderer, this.name, "null", "null",
								 this.bounds, callback);
		this.label = new Label(this.renderer, this.name, "null",
							   this.bounds, text, fontName, color);
	}

	public override void draw() {
		this.button.render();
		this.label.render();
	}


	public override void setXY(int x, int y) {
		this.bounds.x = x;
		this.bounds.y = y;

		this.button.setXY(x, y);
		this.centerLabel();
	}

	public override void centerHorizontally() {
		SDL_Rect *screenRegion = this.renderer.getScreenRegion();
		this.bounds.x = (screenRegion.w - this.bounds.w) / 2;

		this.button.centerHorizontally();
		this.centerLabel();
	}


	/**
	 * center the label within the button's bounds
	 **/
	private void centerLabel() {
		const(SDL_Rect *)labelBounds = this.label.getBounds();
		int labelX = this.bounds.x + (this.bounds.w - labelBounds.w) / 2;
		int labelY = this.bounds.y + (this.bounds.h - labelBounds.h) / 2;

		this.label.setXY(labelX, labelY);
	}

	public override void setBounds(int x, int y, int w, int h) {
		this.bounds.x = x;
		this.bounds.y = y;
		this.bounds.w = w;
		this.bounds.h = h;

		this.button.setBounds(x, y, w, h);
		this.centerLabel();
	}

	public override void click() {
		this.button.click();
	}
}
