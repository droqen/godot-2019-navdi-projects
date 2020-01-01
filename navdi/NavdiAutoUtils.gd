extends Node

var compass = [[1,0],[0,-1],[-1,0],[0,1]]

func get_shuffled_compass():
	shuffle(compass)
	return compass

func shuffle(arr, start = 0, end = 0):
	if end <= 0:
		end = len(arr) + end
	for i in range(start + 1, end):
		var j = start + randi() % (i + 1 - start)
		var t = arr[i]
		arr[i] = arr[j]
		arr[j] = t
	return arr