module color;

class Color {
	public ubyte r;
	public ubyte g;
	public ubyte b;
	public ubyte a;

	public this() {
		this.a = 255;
	}

	public this(ubyte r, ubyte g, ubyte b, ubyte a=255) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}
}
