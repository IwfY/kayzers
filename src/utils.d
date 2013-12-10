module utils;

import rect;

import derelict.sdl2.sdl;

import std.math;


T min(T)(T i, T j) if (is(T : double)) {
	if (i <= j) {
		return i;
	}
	return j;
}

T max(T)(T i, T j) if (is(T : double)) {
	if (i >= j) {
		return i;
	}
	return j;
}


double getDistance(double x1, double y1, double x2, double y2) {
	return sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
}


bool rectContainsPoint(const(SDL_Rect*) rect, int x, int y) {
	if (x < rect.x || y < rect.y) {
		return false;
	}
	if (x > rect.x + rect.w || y > rect.y + rect.h) {
		return false;
	}

	return true;
}


bool rectContainsPoint(const(SDL_Rect*) rect, const(SDL_Point*) point) {
	if (point.x < rect.x || point.y < rect.y) {
		return false;
	}
	if (point.x > rect.x + rect.w || point.y > rect.y + rect.h) {
		return false;
	}

	return true;
}


bool rectContainsPoint(const(Rect) rect, const(SDL_Point*) point) {
	if (point.x < rect.x || point.y < rect.y) {
		return false;
	}
	if (point.x > rect.x + rect.w || point.y > rect.y + rect.h) {
		return false;
	}

	return true;
}

/**
 * get a pseudo randomly distributed hash for two numbers
 **/
bool hash(int i, int j, float falseRatio=0.5) {
	int n1 = (((i + 5) * 991) & 255);
	n1 ^= n1 << 16;
	n1 ^= n1 >> 7;

	int n2 = (((j + 9) * 1171) & 255);
	n2 ^= n2 << 9;
	n2 ^= n2 >> 13;

	int n3 = n1 + n2;
	n3 = n3 % 991;

	return (n3 > (falseRatio * 991));
}
