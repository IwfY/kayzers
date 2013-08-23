module ui.button;

import utils;
import renderhelper;
import ui.widget;

import derelict.sdl2.sdl;


class Button : Widget {
	private void delegate(string) callback;	// callback function pointer
	
	public this(RenderHelper renderer,
				string name,
				string textureName,
				SDL_Rect *bounds,
				void delegate(string) callback) {
		super(renderer, name, textureName, bounds);
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
