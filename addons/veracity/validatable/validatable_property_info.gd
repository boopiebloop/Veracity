# ---------------------------------------------------------------------------------------------- #
##
# ---------------------------------------------------------------------------------------------- #


class_name ValidatablePropertyInfo
extends PropertyInfo


func _init(new_object:Object, new_name:String, new_export:bool = false) -> void:
	_object = Veracity.ensure(new_object)
	_name = Veracity.ensure(new_name, not new_name.is_empty() and new_name in _object)
	_typr = Typr.new(ValidatableResource)
	_export = new_export

func get_validatable() -> ValidatableResource:
	var validatable:ValidatableResource = get_value()
	return validatable
