module script.token;

import script.expressions;

/**
 * token
 **/
class Token {
	public abstract double execute(Expression e1, Expression e2);
};

class AddToken : Token {
	public override double execute(Expression e1, Expression e2) {
		return e1.execute() + e2.execute();
	}
}

class SubToken : Token {
	public override double execute(Expression e1, Expression e2) {
		return e1.execute() - e2.execute();
	}
}

class MulToken : Token {
	public override double execute(Expression e1, Expression e2) {
		return e1.execute() * e2.execute();
	}
}

class DivToken : Token {
	public override double execute(Expression e1, Expression e2) {
		return e1.execute() / e2.execute();
	}
}

/**
 * lesser than
 **/
class LTToken : Token {
	public override double execute(Expression e1, Expression e2) {
		return cast(int)(e1.execute() < e2.execute());
	}
}

/**
 * greater than
 **/
class GTToken : Token {
	public override double execute(Expression e1, Expression e2) {
		return cast(int)(e1.execute() > e2.execute());
	}
}

class EqualToken : Token {
	public override double execute(Expression e1, Expression e2) {
		return cast(int)(e1.execute() == e2.execute());
	}
}
