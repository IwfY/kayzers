module ui.widgets.positionbox;

import position;
import utils;
import ui.renderhelper;
import ui.widgets.widget;
import ui.widgets.widgetinterface;

import derelict.sdl2.sdl;

/**
 * widget container that arranges its children by position
 **/
class PositionBox : Widget {
	private WidgetInterface[] children;
	private Position[] childrenPositions;

	public this(RenderHelper renderer,
	            string name,
	            string textureName,
	            const(SDL_Rect *)bounds = new SDL_Rect()) {
		super(renderer, name, textureName, bounds);
	}

	public override void setZIndex(int zIndex) {
		this.zIndex = zIndex;
		foreach (WidgetInterface widget; this.children) {
			widget.setZIndex(zIndex + 1);
		}
	}

	public void addChild(WidgetInterface child, Position position) {
		this.children ~= child;
		this.childrenPositions ~= position;
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
		int maxWidth = 0;
		int maxHeight = 0;
		for (int i = 0; i < this.children.length; ++i) {
			this.children[i].setXY(
				this.bounds.x + this.childrenPositions[i].i,
				this.bounds.y + this.childrenPositions[i].j);
			const(SDL_Rect*) newBounds = this.children[i].getBounds();
			maxWidth = max(cast(const(int))maxWidth,
			               newBounds.x + newBounds.w);
			maxHeight = max(cast(const(int))maxHeight,
			                newBounds.y + newBounds.h);
		}
		this.bounds.w = maxWidth;
		this.bounds.h = maxHeight;
	}
}