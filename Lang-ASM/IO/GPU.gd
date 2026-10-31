class_name GPU extends Port

var dly:int = 0

const PORT:int = 1

func _init(newDevice:Object) -> void:
	device = newDevice
	for x in 32:
		for y in 32:
			device.set_cell(Vector2i(x, y), 8, Vector2i(1, 0))

func p26(op:int) -> int:
	if !(op >> 5):
		return PORT
	if (op >> 5) == 1:
		#NOTE: Need to implement shader feature
		return PORT
	if (op >> 5) == 2:
		device.set_cell(Vector2i(op & 31, dly), 8, Vector2i(0, 0))
		return PORT
	if (op >> 5) == 3:
		device.set_cell(Vector2i(op & 31, dly), 8, Vector2i(1, 0))
		return PORT
	if (op >> 5) == 4:
		dly = op & 31
		return PORT
	return PORT

func reset() -> void:
	input = 0
	for x in 32:
		for y in 32:
			device.set_cell(Vector2i(x, y), 8, Vector2i(1, 0))
