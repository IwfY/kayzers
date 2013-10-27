module observer;

import message;

interface Observer {
	public void notify(const(Message) message);
}
