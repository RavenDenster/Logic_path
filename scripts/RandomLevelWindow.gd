extends Window

@onready var inputs     = $Margin/VBox/Grid/Inputs
@onready var outputs    = $Margin/VBox/Grid/Outputs
@onready var gates      = $Margin/VBox/Gates

"""
enum Bool2 {
	False, True, Both
}

var allowed_classes: Array[LevelInfo.Post] = []
var required_classes: Array[LevelInfo.Post] = []
var table: Array[Bool2]

func can_set(idx: int, to: Bool2):
	var can: bool = true
	var tab_size: int = (1 << int(inputs.value))
	
	if required_classes.has(LevelInfo.Post.T0) and idx == 0:
		can = can and (to == Bool2.False)
	
	if required_classes.has(LevelInfo.Post.T1) and idx == tab_size - 1:
		can = can and (to == Bool2.True)
		
	if required_classes.has(LevelInfo.Post.S):
		var half: int = tab_size >> 1
		var mirror_idx: int
		if idx < half: mirror_idx = tab_size - 1 - idx
		else:          mirror_idx = idx + 1 - tab_size
		
		if table[mirror_idx] != Bool2.Both:
			can = can and (to != table[mirror_idx])
	
	if required_classes.has(LevelInfo.Post.M):
		var bits = LevelInfo.idx_to_bits(idx, int(inputs.value))
		for i in range(int(inputs.value)):
			if bits[i]:
				bits[i] = false
				var prev_idx = LevelInfo.bits_to_idx(bits)
				bits[i] = true
				if table[prev_idx] != Bool2.Both and to == Bool2.False:
					can = can and (table[prev_idx] == Bool2.False)
			else:
				bits[i] = true
				var next_idx = LevelInfo.bits_to_idx(bits)
				bits[i] = false
				if table[next_idx] != Bool2.Both and to == Bool2.True:
					can = can and (table[next_idx] == Bool2.True)
"""

var cur_inputs: Array[bool] = []
var unused_variables: Array[int] = []
var unused_gates: Array[int] = []

var callable: Dictionary[LevelInfo.GateType, Callable] = {
	LevelInfo.GateType.AND: func(a, b): return a.call() and b.call(),
	LevelInfo.GateType.OR: func(a, b): return a.call() or b.call(),
	LevelInfo.GateType.NAND: func(a, b): return not(a.call() and b.call()),
	LevelInfo.GateType.NOR: func(a, b): return not(a.call() or b.call()),
	LevelInfo.GateType.XOR: func(a, b): return a.call() != b.call(),
	LevelInfo.GateType.XNOR: func(a, b): return a.call() == b.call(),
	LevelInfo.GateType.NOT: func(a): return not a.call(), 
}

var allowed_gates: Array[LevelInfo.GateType]

func _ready() -> void:
	randomize()
	for gate_name in LevelInfo.GateType.keys():
		gates.add_item(gate_name)

func _on_close_requested() -> void:
	visible = false

func _get_value(idx: int) -> bool:
	return cur_inputs[idx]

func get_rand_variable() -> int:
	if unused_variables.is_empty():
		return randi_range(0, int(inputs.value) - 1)
	return unused_variables.pop_back()

func get_rand_gate() -> LevelInfo.GateType:
	if unused_gates.is_empty():
		return allowed_gates[randi_range(0, allowed_gates.size() - 1)]
	return unused_gates.pop_back()

func random_function(cost: int, depth: int = 0) -> Callable:
	var depth_str = ""
	for i in range(depth * 2):
		depth_str += " "
	
	if cost == 0:
		var i = get_rand_variable()
		print(depth_str, "VAR ", i)
		return _get_value.bind(i)
	
	var gate = get_rand_gate()
	
	print(depth_str, LevelInfo.GateType.keys()[gate])
	
	var left = cost - 1
	var costs = []
	for i in range(callable[gate].get_argument_count()):
		var c = randi_range(0, left)
		costs.append(c)
		left -= c
		
	costs[0] += left
	costs.shuffle()
	
	var args = []
	for c in costs:
		args.append(random_function(c, depth + 1))
	
	return callable[gate].bindv(args)

func _on_create_button_pressed() -> void:
	LevelInfo.path = ""
	
	var gate_names = []
	allowed_gates.clear()
	unused_gates.clear()
	for index in gates.get_selected_items():
		unused_gates.append(index)
		allowed_gates.append(index as LevelInfo.GateType)
		gate_names.append(gates.get_item_text(index))
	
	if gate_names.size() == 0:
		MessageDisplay.display_message("Выберите хотя бы один логический элемент")
		return
	
	var input_names = []
	for i in range(int(inputs.value)):
		input_names.append("Вход %d" % [i+1])
	
	var output_names = []
	for i in range(int(outputs.value)):
		output_names.append("Выход %d" % [i+1])
	
	unused_variables.clear()
	for i in range(int(inputs.value)):
		unused_variables.append(i)
		cur_inputs.append(false)
	
	unused_variables.shuffle()
	unused_gates.shuffle()
	
	var truth_table = []
	for i in range(int(outputs.value)):
		var row = []
		while 1:
			row = []
			var cnt_1 = 0
			var f = random_function(10 * int(inputs.value))
			for comb in range(1 << int(inputs.value)):
				for j in range(int(inputs.value)):
					cur_inputs[j] = bool((comb >> j) & 1)
				var res = f.call()
				row.append(res)
				cnt_1 += int(res)
			if cnt_1 != 0: break
			
		truth_table.append(row)
	
	LevelInfo.data["allowed_gates"] = gate_names
	LevelInfo.data["help"] = ""
	LevelInfo.data["n_inputs"] = int(inputs.value)
	LevelInfo.data["n_outputs"] = int(outputs.value)
	LevelInfo.data["input_names"] = input_names
	LevelInfo.data["output_names"] = output_names
	LevelInfo.data["name"] = "Задача"
	LevelInfo.data["truth_table"] = truth_table
	LevelInfo.data["tutorial"] = false
	get_tree().change_scene_to_file("res://scenes/Level.tscn")
