module ui.widgets.containerwidget;

import ui.renderhelper;
import ui.widgets.iwidget;
import ui.widgets.widget;

import derelict.sdl2.sdl;

abstract class ContainerWidget : Widget {
	protected IWidget[] children;

	public this(RenderHelper renderer,
	            const(SDL_Rect *)bounds = new SDL_Rect()) {
		super(renderer, bounds);
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
		foreach (IWidget widget;
				 sort!(IWidget.zIndexSortDesc)(this.children)) {
			widget.render();
		}
	}

	public override void handleEvent(SDL_Event event) {
		foreach (IWidget widget;
				 sort!(IWidget.zIndexSort)(this.children)) {
			widget.handleEvent(event);
		}
	}
}
