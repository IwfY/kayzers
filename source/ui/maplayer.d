module ui.maplayer;

abstract class MapLayer {
	protected int width;
	protected int height;
	
	public this(int width, int height) {
		this.width = width;
		this.height = height;
	}

	/**
	 * get the texture name for the given tile
	 **/
	public abstract string getTextureName(int i, int j);
}
