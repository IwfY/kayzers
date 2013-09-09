module ui.popupbutton;

import renderhelper;
import ui.labelbutton;
import ui.hoverwidget;

import derelict.sdl2.sdl;

class PopupButton : LabelButton {
	public this(RenderHelper renderer,
				string name,
				string textureName,
				string hoverTextureName,
				SDL_Rect *bounds,
				void delegate(string) callback,
				string text,
				string fontName,
				SDL_Color *color = null) {
		super(renderer, name, textureName, hoverTextureName, bounds,
			  callback, text, fontName, color);
		this.label.setTextureName("ui_popup_background");
		this.label.setPadding(5, 3);
		this.label.hide();
	}


	public override void setXY(int x, int y) {
		this.bounds.x = x;
		this.bounds.y = y;

		this.button.setXY(x, y);
		this.centerLabel();
	}

	/**
	 * center the label within the button's bounds
	 **/
	private void centerLabel() {
		const(SDL_Rect *)labelBounds = this.label.getBounds();
		int labelX = this.bounds.x + (this.bounds.w - labelBounds.w) / 2;
		int labelY = this.bounds.y + (this.bounds.h - labelBounds.h) / 2;

		this.label.setXY(labelX, labelY - 30);
	}

	public override void mouseEnter() {
		this.label.unhide();
	}

	public override void mouseLeave() {
		this.label.hide();
	}
}
