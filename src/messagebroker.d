module messagebroker;

import list;
import observer;

class MessageBroker {
	private List!(Observer)[string] observers;

	/**
	 * register an observer to be notified about a given message
	 **/
	public void register(Observer observer, string message) {
		// if there is no list for this message we have to create one
		if (this.observers.get(message, null) is null) {
			this.observers[message] = new List!(Observer)();
		}

		// don't let an observer register for a message multiple times
		if (!this.observers[message].contains(observer)) {
			this.observers[message].append(observer);
		}
	}


	/**
	 * unregister an observer from a given message
	 **/
	public void unregister(Observer observer, string message) {
		List!(Observer) list = this.observers.get(message, null);

		// check if list exists
		if (list is null) {
			return;
		}

		// check if observer is actually registered
		if (list.contains(observer)) {
			list.removeFirst(observer);
		}

	}


	/**
	 * send a notification to every registered observer
	 **/
	public void notify(string message) {
		List!(Observer) list = this.observers.get(message, null);

		// check if list exists
		if (list is null) {
			return;
		}

		foreach (Observer observer; list) {
			observer.notify(message);
		}
	}
}


/*******************************************************************************
 * unit tests
 ******************************************************************************/

///
unittest {
	class A : Observer {
		public int i;
		public this () {
			this.i = 1;
		}
		public void notify(string message) {
			if (message == "event") {
				this.i++;
			} else {
				this.i = -1;
			}
		}
	}

	MessageBroker mb = new MessageBroker();
	A a = new A();
	mb.register(a, "event");
	assert(a.i == 1);
	mb.notify("event");
	assert(a.i == 2);
	mb.notify("other_event");
	assert(a.i == 2);

	mb.unregister(a, "event");
	mb.notify("event");
	assert(a.i == 2);
}
