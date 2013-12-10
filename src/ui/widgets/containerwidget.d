module ui.widgets.containerwidget;

import ui.renderhelper;
import ui.widgets.iwidget;
import ui.widgets.widget;

import derelict.sdl2.sdl;

abstract class ContainerWidget : Widget {
	private IWidget[] children;

	public this(RenderHelper renderer,
	            const(SDL_Rect *)bounds = new SDL_Rect()) {
		super(renderer, bounds);
	}

	public override void setZIndex(int zIndex) {
		this.zIndex = zIndex;
		foreach (IWidget widget; this.children) {
			widget.setZIndex(zIndex + 1);
		}
	}

	public void addChild(IWidget child) {
		this.children ~= child;
		this.updateChildren();
	}

	public override void setXY(int x, int y) {
		super.setXY(x, y);
		this.updateChildren();
	}

	public override void setBounds(int x, int y, int w, int h) {
		super.setBounds(x, y, w, h);
		this.updateChildren();
	}

	public override void setHidden(const(bool) hidden) {
		super.setHidden(hidden);
		foreach (IWidget widget; this.children) {
			widget.setHidden(hidden);
		}
	}

	protected abstract void updateChildren();

	protected override void draw() {
		foreach (IWidget widget; this.children) {
			widget.render();
		}
	}
}
