module position;

alias PositionTemplate!(int) Position;
alias PositionTemplate!(double) PositionDouble;

class PositionTemplate(T) {
	public T i;	// column
	public T j;  // row

	public this() {
		this.i = 0;
		this.j = 0;
	}

	public this(T i, T j) {
		this.i = i;
		this.j = j;
	}
}
