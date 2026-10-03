# ---------------------------------------------------------------------------------------------- #
##
# ---------------------------------------------------------------------------------------------- #


class_name Log


class StackFrame:
	var source:String
	var source_name:String
	var function:String
	var line:int
	func _init(new_source:String, new_function:String, new_line:int) -> void:
		source = new_source
		source_name = source.get_file().get_basename().to_pascal_case()
		function = new_function
		line = new_line
	func _to_string() -> String:
		return "%s.%s:%s" % [source_name, function, line]


const INFO_COLOUR := Color.SKY_BLUE
static func info(msg:String, ignore_last_stack_frame:bool = false) -> void:
	_print_formatted_msg(_extract_stack_frame(ignore_last_stack_frame), "INFO", msg, 
		INFO_COLOUR)

const WARNING_COLOUR := Color.KHAKI
static func warning(msg:String, ignore_last_stack_frame:bool = false) -> void:
	_print_formatted_msg(_extract_stack_frame(ignore_last_stack_frame), "WARNING", msg, 
		WARNING_COLOUR)
	push_warning(msg)

const ERROR_COLOUR := Color.TOMATO
static func error(msg:String, ignore_last_stack_frame:bool = false) -> void:
	_print_formatted_msg(_extract_stack_frame(ignore_last_stack_frame), "ERROR", msg, 
		ERROR_COLOUR)
	push_error(msg)

const CRITICAL_COLOUR := Color.MEDIUM_VIOLET_RED
static func critical(msg:String, ignore_last_stack_frame:bool = false) -> void:
	var stack_frame := _extract_stack_frame(ignore_last_stack_frame)
	_print_formatted_msg(stack_frame, "CRITICAL", msg, CRITICAL_COLOUR)
	assert(false, msg)

static func unreachable(msg:String = "") -> void:
	msg = _format_optional_msg(msg)
	error("Unreachable Statement: " + msg, true)

static func read_only_setter(msg:String = "") -> void:
	msg = _format_optional_msg(msg)
	warning("Attempted to access setter on a read-only property" + msg, true)

static func _extract_stack_frame(offset:int = 0) -> StackFrame:
	var stack := get_stack()
	var stack_frame_index:int = clampi(2 + offset, 0, stack.size() - 1)
	var stack_frame_dict:Dictionary = stack[stack_frame_index]
	var source:String = stack_frame_dict.source
	var function:String = stack_frame_dict.function
	var line:int = stack_frame_dict.line
	return StackFrame.new(source, function, line)

static func get_string_representation(object:Object, included_properties:Array[StringName] = []) -> String:
	if not object:
		return "NULL"
	var obj_class_name := Typr.new(object).get_name()
	var property_values:String = ""
	for property_info in ScriptPropertyList.new(object).get_all():
		var property_name := property_info.get_name()
		if not included_properties.has(property_name):
			continue
		var representation:String = "[indent][code]%s[/code] => %s[/indent]" % [
			property_name, object.get(property_name)]
		property_values += representation
	var string_representation:String = "%s : {%s}" % [obj_class_name, property_values]
	return string_representation

static func _format_rich(frame:StackFrame, badge:String, msg:String, colour:Color) -> String:
	var formatted := "[color=%s][b]○ %s[/b]: [url=%s:%d]%s[/url] - %s[/color]" % [
		colour.to_html(false), badge.to_upper(), frame.source, frame.line, frame, msg]
	return formatted

static func _format_optional_msg(msg:String, default_msg:String = "!") -> String:
	if msg.is_empty():
		return default_msg
	else:
		return ": %s" % msg

static func _print_formatted_msg(frame:StackFrame, badge:String, msg:String, colour:Color) -> void:
	var formatted := "[color=%s][b]• %s[/b]: [url=%s:%d]%s[/url] - %s[/color]" % [
		colour.to_html(false), badge.to_upper(), frame.source, frame.line, frame, msg]
	print_rich(formatted)
