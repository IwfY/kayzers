module script.expressions;

import utils;
import script.script;
import script.scriptcontext;
import script.token;
import world.nation;
import world.resourcemanager;

import std.conv;

/**
 * expressions
 **/

class Expression {
	private Script script;

	public this(Script script) {
		this.script = script;
	}

	public abstract double execute();
}


class Identifier : Expression {
	private string name;
	private double value;

	public this(Script script, string name) {
		super(script);
		this.name = name;
		this.value = 0.0;
	}

	public void assign(double value) {
		this.value = value;
	}

	public double getValue() {
		return this.value;
	}

	public override double execute() {
		return this.getValue();
	}
}


class ResourceIdentifier : Identifier {
	private string resourceName;

	public this(Script script, string name) {
		super(script, name);
		this.resourceName = name[4..name.length];
	}

	public override void assign(double value) {
		ScriptContext context = this.script.getContext();
		ResourceManager resources = context.getResources();

		return resources.setResource(this.resourceName, value);
	}

	public override double getValue() {
		ScriptContext context = this.script.getContext();
		const(ResourceManager) resources = context.getResources();

		return resources.getResourceAmount(this.resourceName);
	}
}


class GlobalResourceIdentifier : Identifier {
	private string resourceName;

	public this(Script script, string name) {
		super(script, name);
		this.resourceName = name[5..name.length];
	}

	public override void assign(double value) {
		ScriptContext context = this.script.getContext();
		Nation nation = context.getNation();
		ResourceManager resources = nation.getResources();

		return resources.setResource(this.resourceName, value);
	}

	public override double getValue() {
		ScriptContext context = this.script.getContext();
		const(Nation) nation = context.getNation();
		const(ResourceManager) resources = nation.getResources();

		return resources.getResourceAmount(this.resourceName);
	}
}


class ConsumeExpression : Expression {
	private string resourceName;
	private Expression amountExpression;

	public this(Script script, string name, Expression amountExpression) {
		super(script);
		this.resourceName = name;
		this.amountExpression = amountExpression;
	}

	public override double execute() {
		ScriptContext context = this.script.getContext();
		Nation nation = context.getNation();
		double amount = this.amountExpression.execute();

		return nation.consume(this.resourceName, amount);
	}
}


class ProduceExpression : Expression {
	private string resourceName;
	private Expression amountExpression;

	public this(Script script, string name, Expression amountExpression) {
		super(script);
		this.resourceName = name;
		this.amountExpression = amountExpression;
	}

	public override double execute() {
		ScriptContext context = this.script.getContext();
		Nation nation = context.getNation();
		double amount = this.amountExpression.execute();

		return nation.produce(context, this.resourceName, amount);
	}
}


class Number : Expression {
	private double value;

	public this(Script script, string text) {
		super(script);
		this.value = to!(double)(text);
	}

	public override double execute() {
		return this.value;
	}
}


/**
 * expression of the form
 * 		Identifier Token Number
 **/
class BinaryExpression : Expression {
	private Expression e1;
	private Expression e2;
	private Token token;

	public this(Script script, Expression e1, Expression e2, Token token) {
		super(script);
		this.e1 = e1;
		this.e2 = e2;
		this.token = token;

	}

	public override double execute() {
		return this.token.execute(e1, e2);
	}
}

/**
 * expression of the form:
 * 		Identifier = Expression
 **/
class AssignExpression : Expression {
	private Identifier identifier;
	private Expression expression;

	public this(Script script, Identifier identifier, Expression expression) {
		super(script);
		this.identifier = identifier;
		this.expression = expression;
	}

	public override double execute() {
		this.identifier.assign(this.expression.execute());
		return 0.0;
	}
}


/**
 * expression of the form:
 * 		if (condition) action
 **/
class IfExpression : Expression {
	private Expression condition;
	private Expression action;

	public this(Script script, Expression condition, Expression action) {
		super(script);
		this.condition = condition;
		this.action = action;
	}

	public override double execute() {
		if (this.condition.execute() != 0.0) {
			this.action.execute();
		}
		return 0.0;
	}
}


class MinExpression : Expression {
	private Expression e1;
	private Expression e2;

	public this(Script script, Expression e1, Expression e2) {
		super(script);
		this.e1 = e1;
		this.e2 = e2;
	}

	public override double execute() {
		return min(e1.execute(), e2.execute());
	}
}


class MaxExpression : Expression {
	private Expression e1;
	private Expression e2;

	public this(Script script, Expression e1, Expression e2) {
		super(script);
		this.e1 = e1;
		this.e2 = e2;
	}

	public override double execute() {
		return max(e1.execute(), e2.execute());
	}
}
