module list;

class List(T) {
	private T[] list;

	public this() {
	}

	public size_t length() {
		return this.list.length;
	}

	public void append(T t) {
		this.list ~= t;
	}


	/**
	 * get item at the given index
	 **/
	public T get(ulong i)
		in {
			assert(i >= 0, "List::get index < 0");
			assert(i < this.list.length, "List::get index > lenght");
		}
		body {
			return this.list[i];
		}


	/**
	 * remove the item at the given index; return removed item
	 **/
	public T removeIndex(ulong i)
		in {
			assert(i >= 0, "List::removeIndex index < 0");
			assert(i < this.list.length, "List::removeIndex index > lenght");
		}
		body {
			T ret = this.list[i];
			this.list =
					this.list[0..i] ~
					this.list[(i + 1) .. this.list.length];

			return ret;
		}


	/**
	 * remove the first occurance of the given item from the list
	 * return removed item
	 **/
	public T removeFirst(T t)
		in {
			assert(this.contains(t));
		}
		body {
			ulong index = 0;
			for (int i = 0; i < this.list.length; ++i) {
				if (this.list[i] == t) {
					index = i;
					break;
				}
			}

			return this.removeIndex(index);
		}


	/**
	 * check if the item is contained in the list
	 **/
	public bool contains(T t) {
		foreach (T tCursor; this.list) {
			if (tCursor == t) {
				return true;
			}
		}

		return false;
	}


	/**
	 * method used by foreach statement
	 *
	 * see http://dlang.org/statement.html#ForeachStatement
	 **/
	public int opApply(int delegate(ref T) dg) {
		int result;

		for (ulong i = 0; i < this.list.length; ++i) {
			result = dg(this.list[i]);
			if (result) {
				break;
			}
		}
		return result;
	}

	public int opApply(int delegate(ref const(T)) dg) const {
		int result;

		for (ulong i = 0; i < this.list.length; ++i) {
			result = dg(this.list[i]);
			if (result) {
				break;
			}
		}
		return result;
	}

	/**
	 * overload for "~=" operator
	 **/
	public void opOpAssign(string op)(T t) {
		if (op == "~") {
			list ~= t;
		}
	}
}

/**
 * unit tests
 **/

unittest {
	class A {
		public int a;
		public this(int a) {this.a = a;}
	}
	A a1 = new A(1);
	A a2 = new A(2);
	A a3 = new A(19);
	A a4 = new A(19);

	List!(A) c = new List!(A)();
	assert(c.length == 0);
	c.append(a1);
	c.append(a2);
	c.append(a3);
	assert(c.length == 3);
	assert(c.get(0) == a1);

	assert(c.contains(a3) == true);
	assert(c.contains(a4) == false);

	assert(c.removeFirst(a2) == a2);
	assert(c.length == 2);
	assert(c.get(1) == a3);
}

unittest {
	List!(int) c = new List!(int)();
	c.append(5);
	assert(c.get(0) == 5);
}

///
unittest {
	List!(int) c = new List!(int)();
	c.append(20);
	c.append(30);

	int i = 0;
	foreach(int j; c) {
		if (i == 0) {
			assert(j == 20);
		} else if (i == 1) {
			assert(j == 30);
		}

		++i;
	}
}

unittest {
	List!(int) c = new List!(int)();
	c ~= 20;
	c ~= 30;

	int i = 0;
	foreach(int j; c) {
		if (i == 0) {
			assert(j == 20);
		} else if (i == 1) {
			assert(j == 30);
		}

		++i;
	}
}

unittest {
	List!(int) c = new List!(int)();

	foreach(int i; c) {
		;
	}
}
