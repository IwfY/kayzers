module ui.widgets.positionbox;

import position;
import utils;
import ui.renderhelper;
import ui.widgets.containerwidget;
import ui.widgets.iwidget;

import derelict.sdl2.sdl;

/**
 * widget container that arranges its children by position
 **/
class PositionBox : ContainerWidget {
	private IWidget[] children;
	private Position[] childrenPositions;

	public this(RenderHelper renderer,
	            const(SDL_Rect *)bounds = new SDL_Rect()) {
		super(renderer, bounds);
	}

	protected void updateChildren() {
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
