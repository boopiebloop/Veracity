# ---------------------------------------------------------------------------------------------- #
##
# ---------------------------------------------------------------------------------------------- #


@tool
class_name ScriptPropertyList
extends RefCounted


var _object:Object
var _name_info_map:Dictionary[StringName, PropertyInfo] = {}
var _list:Array[PropertyInfo]:
	get:
		return _name_info_map.values()

func get_all() -> Array[PropertyInfo]:
	return _list

func _init(new_object:Object) -> void:
	Veracity.ensure(new_object)
	_object = new_object
	for dict in _object.get_property_list():
		var usage:PropertyUsageFlags = Veracity.ensure(dict.get("usage"))
		if usage & PropertyUsageFlags.PROPERTY_USAGE_SCRIPT_VARIABLE:
			var property_name:String = Veracity.ensure(dict.get("name"))
			var property_class_name:String = Veracity.ensure(dict.get("class_name"))
			var property_type:Variant.Type = Veracity.ensure(dict.get("type"))
			var property_typr := Typr.from_ambiguous(property_class_name, property_type)
			var property_exported:bool = usage & PropertyUsageFlags.PROPERTY_USAGE_STORAGE
			var info:PropertyInfo
			if property_typr.inherits(ValidatableResource):
				info = ValidatablePropertyInfo.new(_object, property_name, property_exported)
			else:
				info = PropertyInfo.new(_object, property_name, property_typr, property_exported)
			_list.append(info)
			_name_info_map[property_name] = info

func has_typr(typr:Typr) -> bool:
	return not get_of_typr(typr) == null

func get_of_typr(typr:Typr) -> Variant:
	for info in _list:
		if typr.same_as(info.get_typr()):
			return info.get_value()
	return null

func get_all_of_typr(typr:Typr) -> Array:
	var variants:Array[Variant] = []
	for info in _list:
		if typr.same_as(info.get_typr()):
			var value:Variant = info.get_value()
			if value:
				variants.append(value)
	return variants

func has_null(ignored_properties:Array[StringName] = []) -> bool:
	for info in _list:
		if ignored_properties.has(info.get_name()):
			continue
		elif info.get_value() == null:
			return true
	return false

func get_info(name:String) -> PropertyInfo:
	return _name_info_map.get(name)

func has_info(info:PropertyInfo) -> bool:
	return has_property(info.get_name())

func has_property(name:String) -> bool:
	return _name_info_map.has(name)
