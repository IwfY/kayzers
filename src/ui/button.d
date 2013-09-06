module ui.button;

import utils;
import renderhelper;
import ui.hoverwidget;

import derelict.sdl2.sdl;


class Button : HoverWidget {
	private void delegate(string) callback;	// callback function pointer
	
	public this(RenderHelper renderer,
				string name,
				string textureName,
				string hoverTextureName,
				SDL_Rect *bounds,
				void delegate(string) callback) {
		super(renderer, name, textureName, hoverTextureName, bounds);
		this.callback = callback;
	}
				
	
	override public void click() {
		this.callback(this.name);
	}

	public override void draw() {
	}
	
	//public void render() {
		//this.renderer.drawTexture(this.bounds.x, this.bounds.y,
								  //this.textureName);
	//}
}
