# ---------------------------------------------------------------------------------------------- #
##
# ---------------------------------------------------------------------------------------------- #


class_name PropertyInfo
extends RefCounted


var _object:Object
func get_object() -> Object:
	return _object

var _name:String
func get_name() -> String:
	return _name

var _typr:Typr
func has_typr() -> bool:
	return not _typr
func get_typr() -> Typr:
	return _typr

var _export:bool
func is_export() -> bool:
	return _export

func _init(new_object:Object, new_name:String, new_typr:Typr, new_export:bool = false) -> void:
	_object = Veracity.ensure(new_object)
	Veracity.enforce(not new_name.is_empty())
	_name = new_name
	_typr = Veracity.ensure(new_typr)
	_export = new_export

func get_value() -> Variant:
	return _object.get(_name)

func is_valid() -> bool:
	return not get_value() == null

func set_value(new_value:Variant) -> void:
	_object.set(_name, new_value)
