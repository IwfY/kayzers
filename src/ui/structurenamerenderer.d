module ui.structurenamerenderer;

import client;
import constants;
import textinput;
import ui.inputbox;
import ui.label;
import ui.labelbutton;
import ui.renderer;
import ui.renderhelper;
import ui.widget;
import world.structure;

import derelict.sdl2.sdl;

class StructureNameRenderer : Renderer {
	private const(Structure) structure;

	private bool active;

	// top left coordinates of the message box
	private int boxX;
	private int boxY;

	private Widget[] allWidgets;
	private Widget mouseOverWidget;	// reference to widget under mouse
	private Label label;
	private InputBox inputBox;
	private LabelButton okButton;
	private TextInput textInputServer;
	private string inputString;

	public this(Client client, RenderHelper renderer, const(Structure) structure) {
		super(client, renderer);
		this.textInputServer = new TextInput();
		this.structure = structure;

		this.initWidgets();
		this.active = true;
	}


	public ~this() {
		destroy(this.textInputServer);
	}


	private void initWidgets() {
		this.inputBox = new InputBox(
			this.renderer, this.textInputServer,
			"inputBox", "mainmenu_button",
			new SDL_Rect(0, 0, 260, 30),
			STD_FONT);
		this.allWidgets ~= this.inputBox;

		this.inputBox.setTextPointer(&this.inputString);

		this.okButton = new LabelButton(
			this.renderer,
			"okButton",
			"mainmenu_button",
			"mainmenu_button_hover",
			new SDL_Rect(0, 0, 100, 30),
			&(this.okButtonCallback),
			"OK",
			STD_FONT);
		this.allWidgets ~= this.okButton;

		this.label = new Label(
			this.renderer, "", NULL_TEXTURE,
			new SDL_Rect(0, 0, 280, 25),
			"Name your new town:",
			STD_FONT);
		this.allWidgets ~= this.label;
	}


	private void okButtonCallback(string message) {
		this.client.setStructureName(this.structure, this.inputString);
		this.active = false;
	}


	private void updateWidgets() {
		this.label.setXY(this.boxX + 20,
		                 this.boxY + 20);
		this.inputBox.setXY(this.boxX + 20,
		                    this.boxY + 50);
		this.okButton.setXY(this.boxX + 180,
		                    this.boxY + 90);
	}


	public override void render(int tick=0) {
		if (this.active) {
			this.boxX = this.screenRegion.x + (this.screenRegion.w - 300) / 2;
			this.boxY = this.screenRegion.y + (this.screenRegion.h - 140) / 2;

			this.renderer.drawTexture(this.screenRegion, "grey_a127");
			this.renderer.drawTexture(this.boxX, this.boxY, "bg_300_140");

			this.updateWidgets();
			foreach (Widget widget; this.allWidgets) {
				widget.render();
			}
		}
	}


	public bool isActive() {
		return this.active;
	}

	public override void handleEvent(SDL_Event event) {
		if (this.active) {
			this.textInputServer.handleEvent(event);

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
			// key press
			else if (event.type == SDL_KEYDOWN) {
				// enter input
				if (event.key.keysym.sym == SDLK_RETURN) {
					this.okButtonCallback("");
				}
			}
		}
	}
}

