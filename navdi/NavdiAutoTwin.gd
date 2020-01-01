extends Node

static func taxicab_length(a):
	return abs(a[0])+abs(a[1])
static func add(a,b):
	return [a[0]+b[0],a[1]+b[1]]
static func multiply(a,b):
	return [a[0]*b[0],a[1]*b[1]]
static func subtract(a,b):
	return [a[0]-b[0],a[1]-b[1]]
static func negate(a):
	return [-a.x, -a.y]