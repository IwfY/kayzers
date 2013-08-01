module utils;

import derelict.sdl2.sdl;

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


bool rectContainsPoint(SDL_Rect *rect, SDL_Point *point) {
	if (point.x < rect.x || point.y < rect.y) {
		return false;
	}
	if (point.x > rect.x + rect.w || point.y > rect.y + rect.h) {
		return false;
	}
	
	return true;
}
