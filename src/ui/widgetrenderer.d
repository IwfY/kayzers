module ui.widgetrenderer;

import client;
import ui.renderer;
import ui.renderhelper;
import ui.widgets.iwidget;

import derelict.sdl2.sdl;

import std.algorithm;

abstract class WidgetRenderer : Renderer {
	protected string backgroundImage;
	protected IWidget[] allWidgets;

	public this(Client client, RenderHelper renderer, string backgroundImage) {
		super(client, renderer);
		this.backgroundImage = backgroundImage;

		this.initWidgets();
	}

	protected abstract void initWidgets();

	protected abstract void updateWidgets();


	public override void render(int tick=0) {
		this.updateWidgets();
		this.renderer.drawTexture(this.screenRegion, this.backgroundImage);
		foreach (IWidget widget;
				 sort!(IWidget.zIndexSort)(this.allWidgets)) {
			widget.render();
		}
	}

	protected void addWidget(IWidget widget) {
		this.allWidgets ~= widget;
	}

	protected void clearWidgets() {
		this.allWidgets.length = 0;
	}

	public override void handleEvent(SDL_Event event) {
		foreach (IWidget widget;
				 sort!(IWidget.zIndexSortDesc)(this.allWidgets)) {
			widget.handleEvent(event);
		}
	}

}
