@abstract class_name Port extends RefCounted

var input:int
var output:int
var device:Object

@abstract func _init(newDevice:Object) -> void

@abstract func p26(op:int) -> int

@abstract func reset() -> void
