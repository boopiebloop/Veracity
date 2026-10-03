	# ---------------------------------------------------------------------------------------------- #
##
# ---------------------------------------------------------------------------------------------- #


@tool
@abstract
class_name ValidatableResource
extends Resource

var _valid:bool = false

var _exported_property_infos:Array[PropertyInfo] = []

var _validatable_dependencies:Array[ValidatableResource] = []
func is_validatable_dependency(validatable:ValidatableResource) -> bool:
	if Veracity.catch_null(validatable):
		return false
	else:
		return _validatable_dependencies.has(validatable)

var _invalid_property_infos:Array[PropertyInfo] = []
func get_invalid_properties() -> Array[PropertyInfo]:
	return _invalid_property_infos

var _list:ScriptPropertyList
func erase_validatable_dependency(validatable:ValidatableResource) -> void:
	if not Veracity.catch_null(validatable):
		return
	else:
		_validatable_dependencies.erase(validatable)

var _nullable_properties:Array[StringName] = []


func _init() -> void:
	_list = ScriptPropertyList.new(self)
	_nullable_properties = _get_nullable_properties()
	for info in _list.get_all():
		if _nullable_properties.has(info.get_name()):
			continue
		elif info is ValidatablePropertyInfo:
			var validatable_info:ValidatablePropertyInfo = info
			_initiate_validatable_property(validatable_info)
		if info.is_export():
			_exported_property_infos.append(info)
		else:
			_update_property_validity(info)

func is_valid() -> bool:
	return _invalid_property_infos.is_empty()

func _validate() -> bool:
	var identifier := _get_identifier()
	var valid := is_valid()
	if not valid:
		var errors:String = ""
		for info in _invalid_property_infos:
			errors += "\n[indent]%s[/indent]" % str(info)
		Log.critical("Invalid properties (%s): %s" % [identifier, errors])
	return valid

func _invalid_properties_error(invalid_properties:Array[PropertyInfo]) -> void:
	if invalid_properties.is_empty():
		return
	var errors:String = ""
	for info in invalid_properties:
		errors += "\n%s" % str(info)
	var global_name := Typr.new(self).get_name()
	print_rich("[color=red]Invalid properties %s @ %s: [indent]%s[/indent][/color=red]" % [
		global_name, resource_path, errors])
	Log.critical("Invalid properties %s @ %s! Check log for more details." % [
		global_name, resource_path])

func _update_property_validity(info:PropertyInfo) -> void:
	Veracity.enforce(_list.has_info(info))
	if _get_nullable_properties().has(info.get_name()):
		return
	var value := info.get_value()
	var valid := not value == null
	if info is ValidatablePropertyInfo:
		var validatable_property_info:ValidatablePropertyInfo = info
		valid = _is_validatable_valid(validatable_property_info)
	if not valid:
		_valid = false
		if not _invalid_property_infos.has(info):
			_invalid_property_infos.append(info)
	else:
		if _invalid_property_infos.has(info):
			_invalid_property_infos.erase(info)

func _get_nullable_properties() -> Array[StringName]:
	return []

func _get_validatable_resources() -> Array[ValidatableResource]:
	var validatables:Array[ValidatableResource] = ScriptPropertyList.new(self).get_all_of_typr(
		Typr.new(ValidatableResource))
	return validatables

func _set(property_name: StringName, _value: Variant) -> bool:
	if _list and _list.has_property(property_name):
		_update_property_validity(_list.get_info(property_name))
	return false

func _get_identifier() -> String:
	return "[%s] %s @ %s" % [Typr.new(self).get_name(), resource_name, resource_path]

func _is_validatable_valid(info:ValidatablePropertyInfo) -> bool:
	if Veracity.catch_null(info):
		return false
	var validatable := info.get_validatable()
	if not validatable:
		return false
	elif _nullable_properties.has(info.get_name()):
		return true
	elif not _validatable_dependencies.has(validatable):
		return true
	else:
		return validatable.is_valid()

func _initiate_validatable_property(info:ValidatablePropertyInfo) -> void:
	if Veracity.catch_null(info):
		return
	var validatable := info.get_validatable()
	if not Veracity.catch_null(validatable):
		_validatable_dependencies.append(validatable)
		erase_validatable_dependency(self)
