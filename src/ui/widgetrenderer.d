module ui.widgetrenderer;

import client;
import ui.renderer;
import ui.renderhelper;
import ui.widget;
import world.scenario;

import derelict.sdl2.sdl;

abstract class WidgetRenderer : Renderer {
	protected string backgroundImage;
	protected Widget[] allWidgets;
	protected Widget mouseOverWidget;	// reference to widget under mouse

	public this(Client client, RenderHelper renderer, string backgroundImage) {
		super(client, renderer);
		this.backgroundImage = backgroundImage;
		this.mouseOverWidget = null;

		this.initWidgets();
	}

	protected abstract void initWidgets();

	protected abstract void updateWidgets();


	public override void render(int tick=0) {
		this.updateWidgets();
		this.renderer.drawTexture(this.screenRegion, this.backgroundImage);
		foreach (Widget widget; this.allWidgets) {
			widget.render();
		}
	}

	public override void handleEvent(SDL_Event event) {
		// left mouse down
		if (event.type == SDL_MOUSEBUTTONDOWN &&
				event.button.button == SDL_BUTTON_LEFT) {
			SDL_Point *mousePosition =
					new SDL_Point(event.button.x, event.button.y);
			foreach (Widget widget; this.allWidgets) {
				if (widget.isPointInBounds(mousePosition)) {
					widget.click();
				}
			}
		}
		// mouse motion --> hover effects
		else if (event.type == SDL_MOUSEMOTION) {
			SDL_Point *mousePosition =
					new SDL_Point(event.button.x, event.button.y);
			bool widgetMouseOver = false; // is there a widget under the mouse?
			foreach (Widget widget; this.allWidgets) {
				if (widget.isPointInBounds(mousePosition)) {
					widgetMouseOver = true;
					if (this.mouseOverWidget is null) {
						this.mouseOverWidget = widget;
						this.mouseOverWidget.mouseEnter();
						break;
					} else if (this.mouseOverWidget != widget) {
						this.mouseOverWidget.mouseLeave();
						this.mouseOverWidget = widget;
						this.mouseOverWidget.mouseEnter();
						break;
					}
				}
			}
			// no widget under mouse but there was one before
			if (!widgetMouseOver && this.mouseOverWidget !is null) {
				this.mouseOverWidget.mouseLeave();
				this.mouseOverWidget = null;
			}
		}
	}

}
