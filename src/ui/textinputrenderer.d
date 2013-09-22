module ui.textinputrenderer;

import client;
import constants;
import textinput;
import ui.renderer;
import ui.renderhelper;
import ui.renderstate;
import ui.labelbutton;
import ui.inputbox;
import ui.widget;

import derelict.sdl2.sdl;

class TextInputRenderer : Renderer {
	private string textInput;
	private Widget[] allWidgets;
	private Widget mouseOverWidget;	// reference to widget under mouse
	private InputBox inputBox;
	private LabelButton okButton;
	private TextInput textInputServer;
	private RenderState renderState;
	
	private string *textPointer;


	public this(Client client, RenderHelper renderer, RenderState renderState) {
		super(client, renderer);
		
		this.renderState = renderState;
		this.textInputServer = new TextInput();

		this.initWidgets();
	}


	private void initWidgets() {
		this.inputBox = new InputBox(
				this.renderer, this.textInputServer,
				"inputBox", "mainmenu_button",
				new SDL_Rect(this.screenRegion.x, this.screenRegion.y, 200, 30),
				STD_FONT);
		this.allWidgets ~= this.inputBox;

		this.okButton = new LabelButton(
				this.renderer,
				"okButton",
				"mainmenu_button",
				"mainmenu_button_hover",
				new SDL_Rect(0, 0, 70, 30),
				&(this.okButtonCallback),
				"OK",
				STD_FONT);
		this.allWidgets ~= this.okButton;
	}


	public void setTextPointer(string *textPointer) {
		this.inputBox.setTextPointer(textPointer);
	}


	private void okButtonCallback(string message) {
		this.renderState.restoreState();
		// set pointers to zero
		this.inputBox.setTextPointer(null);
	}


	private void updateWidgets() {
		this.okButton.setXY(this.screenRegion.x + 130,
							this.screenRegion.y + 50);
		this.inputBox.setXY(this.screenRegion.x + 10,
							this.screenRegion.y + 10);
	}


	public override void render() {
		this.updateWidgets();
		this.renderer.drawTexture(this.screenRegion, "mainmenu_bg");

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
