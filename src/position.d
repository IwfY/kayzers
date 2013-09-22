module position;

class Position {
	public int i;	// column
	public int j;  // row

	public this() {
		this.i = 0;
		this.j = 0;
	}
	
	public this(int i, int j) {
		this.i = i;
		this.j = j;
	}
}
