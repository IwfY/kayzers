module observable;

import message;
import observer;

class Observable {
	private Observer[] observers;
	private int maxNumberOfObservers;

	public this(int maxNumberOfObservers = -1) {
		this.maxNumberOfObservers = maxNumberOfObservers;
	}

	public bool registerObserver(Observer observer) {
		if ((this.maxNumberOfObservers >= 0) &&
				(this.observers.length >= this.maxNumberOfObservers)) {
			return false;
		}
		this.observers ~= observer;
		return true;
	}

	public void unregisterObserver(Observer observer) {
		Observer[] newObservers;
		foreach (Observer observerCursor; this.observers) {
			if (observerCursor != observer) {
				newObservers ~= observerCursor;
			}
		}

		this.observers = newObservers;
	}

	protected void notifyObservers() {
		foreach (Observer observer; this.observers) {
			observer.notify(new Message(""));
		}
	}
}
