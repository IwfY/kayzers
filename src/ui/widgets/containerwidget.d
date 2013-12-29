module ui.widgets.containerwidget;

import std.algorithm;

import derelict.sdl2.sdl;

import ui.renderhelper;
import ui.widgets.iwidget;
import ui.widgets.widget;

abstract class ContainerWidget : Widget {
	protected IWidget[] children;
	protected bool dirty;

	public this(RenderHelper renderer,
	            const(SDL_Rect *)bounds = new SDL_Rect()) {
		super(renderer, bounds);

		this.dirty = true;
	}

	public void addChild(IWidget child) {
		this.children ~= child;
		this.dirty = true;
	}

	public void removeChildren() {
		this.children.length = 0;
		this.dirty = true;
	}

	public override void setXY(int x, int y) {
		super.setXY(x, y);
		this.dirty = true;
	}

	public override void setBounds(int x, int y, int w, int h) {
		super.setBounds(x, y, w, h);
		this.dirty = true;
	}

	public override void setHidden(const(bool) hidden) {
		super.setHidden(hidden);
		foreach (IWidget widget; this.children) {
			widget.setHidden(hidden);
		}
	}

	protected abstract void updateChildren();

	protected override void draw() {
		if (this.dirty) {
			this.updateChildren();
			this.dirty = false;
		}

		foreach (IWidget widget;
				 sort!(IWidget.zIndexSort)(this.children)) {
			widget.render();
		}
	}

	public override void handleEvent(SDL_Event event) {
		foreach (IWidget widget;
				 sort!(IWidget.zIndexSortDesc)(this.children)) {
			widget.handleEvent(event);
		}
	}
}
