module ui.widgets.hbox;

import utils;
import ui.renderhelper;
import ui.widgets.widget;
import ui.widgets.widgetinterface;

import derelict.sdl2.sdl;

/**
 * widget container that arranges its children horizontally
 **/
class HBox : Widget {
	private WidgetInterface[] children;
	private int margin;	// vertical gap between child widgets

	public this(RenderHelper renderer,
	            string name,
	            string textureName,
	            const(SDL_Rect *)bounds = new SDL_Rect()) {
		super(renderer, name, textureName, bounds);
		this.margin = 5;
	}


	public const(int) getMargin() const {
		return this.margin;
	}
	public void setMargin(int margin) {
		this.margin = margin;
		this.arrangeChildren();
	}

	public override void setZIndex(int zIndex) {
		this.zIndex = zIndex;
		foreach (WidgetInterface widget; this.children) {
			widget.setZIndex(zIndex + 1);
		}
	}

	public void addChild(WidgetInterface child) {
		this.children ~= child;
		this.arrangeChildren();
	}

	protected override void draw() {
	}


	public override void hide() {
		super.hide();
		foreach (WidgetInterface widget; this.children) {
			widget.hide();
		}
	}
	public override void unhide() {
		super.unhide();
		foreach (WidgetInterface widget; this.children) {
			widget.unhide();
		}
	}


	public override void setXY(int x, int y) {
		this.bounds.x = x;
		this.bounds.y = y;
		this.arrangeChildren();
	}

	public override void setBounds(int x, int y, int w, int h) {
		this.bounds.x = x;
		this.bounds.y = y;
		this.arrangeChildren();
	}

	private void arrangeChildren() {
		int x = this.bounds.x;
		int maxHeight = 0;
		foreach (WidgetInterface widget; this.children) {
			widget.setXY(x, this.bounds.y);
			x += widget.getBounds().w + this.margin;
			maxHeight = max(cast(const(int))maxHeight, widget.getBounds().h);
		}
		this.bounds.h = maxHeight;
		this.bounds.w = x;
	}
}

