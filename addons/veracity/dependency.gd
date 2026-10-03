# ---------------------------------------------------------------------------------------------- #
##
# ---------------------------------------------------------------------------------------------- #


@tool
class_name Dependency


## Returns an all child [Node] of [param node], including children of children.
static func get_all_child_nodes(node:Node) -> Array[Node]:
	var children:Array[Node] = [node]
	for child:Node in node.get_children():
		children.append_array(get_all_child_nodes(child))
	return children

static func try_get_child_of_type(node:Node, type:Variant, check_indirect:bool = false) -> Node:
	if Veracity.catch_null([node, type]):
		return null
	var typr := Typr.new(type)
	var children:Array[Node] = []
	if check_indirect:
		children = get_all_child_nodes(node)
	else:
		children = node.get_children()
	return typr.screen_get(children)

static func try_get_child(node:Node, name:String, check_indirect:bool = false) -> Node:
	if Veracity.catch_null(node):
		return null
	var children:Array[Node] = []
	if check_indirect:
		children = get_all_child_nodes(node)
	else:
		children = node.get_children()
	for child in children:
		if child.name == name:
			return child
	return null

static func establish_parent(node:Node, type:Variant) -> Node:
	if Veracity.catch_null([node, type]):
		return null
	var parent := node.get_parent()
	var typr := Typr.new(type)
	if not parent or not typr.inherited_by(parent):
		Log.error("Parent %s dependency of child %s could not be satisfied!" % [typr, node.get_path()])
		parent = null
	return parent

static func add_and_get_child(node:Node, child:Node) -> Node:
	node.add_child(child)
	return child
