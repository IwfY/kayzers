module utils;

import std.math;

int min(int i, int j) {
	if (i <= j) {
		return i;
	}
	return j;
}

int max(int i, int j) {
	if (i >= j) {
		return i;
	}
	return j;
}


double getDistance(double x1, double y1, double x2, double y2) {
	return sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
}
