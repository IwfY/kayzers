module ui.labelbutton;

import constants;
import rect;
import ui.widgets.button;
import ui.widgets.containerwidget;
import ui.widgets.label;
import ui.renderhelper;

import derelict.sdl2.sdl;

class LabelButton : ContainerWidget {
	protected Button button;
	protected Label label;

	public this(RenderHelper renderer,
				string name,
				string textureName,
				string hoverTextureName,
				SDL_Rect *bounds,
				void delegate(string) callback,
				string text,
				string fontName = STD_FONT,
				SDL_Color *color = null) {
		super(renderer, textureName, hoverTextureName, bounds);

		this.button = new Button(this.renderer, this.name, "null", "null",
								 callback, this.bounds);
		this.button.setZIndex(1);
		this.addChild(this.button);

		this.label = new Label(this.renderer, text, fontName, color);
		this.label.setZIndex(2);
		this.addChild(this.label);
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

	protected override void updateChildren() {
		this.button.setBounds(this.x(), this.y(), this.w(), this.h());
		this.centerLabel();
	}
}
