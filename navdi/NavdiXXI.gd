extends Node
class_name NavdiXXI

var bank:Node
	
func spawn(node_name, group_name=null, position=null):
	if not bank:
		print("cannot spawn "+node_name+" (init_bank has not been called)")
	if bank.has_node(node_name):
		if group_name==null: group_name=node_name+"s"
		var group = get_group(group_name)
		var n = bank.get_node(node_name).duplicate()
		group.add_child(n)
		if position!=null: n.position = position
		return n
	else:
		print("cannot spawn "+node_name+" (it is not in the bank)")
	
func get_group(group_name) -> Node:
	if not has_node(group_name):
		var node = Node.new()
		node.set_name(group_name)
		add_child(node)
	return get_node(group_name)

func init_bank(bank_name = "bank"):
	bank = get_node("bank")
	remove_child(bank)