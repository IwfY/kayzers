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


	/**
	 * overload the '<<' operator to assign values
	 **/
	public void opBinary(string op)
						(const(PositionTemplate!(T)) pos) {
		if (op == "<<") {
			this.i = pos.i;
			this.j = pos.j;
		}
	}

	///
	unittest {
		PositionTemplate!(int) pos1 = new PositionTemplate!(int)(1, 8);
		PositionTemplate!(int) pos2 = new PositionTemplate!(int)();
		assert(pos2.i == 0);
		pos2 << pos1;
		assert(pos2.i == 1);
	}
}
