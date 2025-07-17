extends Control

var is_dragging := false
var cur_card = { # 当前drag card
	"target": null,
	"s_pos": Vector2.ZERO
} 
var start_position := Vector2.ZERO # 开始拖动位置坐标
var cur_card_pos := Vector2.ZERO #当前卡片位置信息

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent):
	_card_darg_input(event)
	
func _card_darg_input(event: InputEvent) -> void:
	var is_touch_event = event is InputEventScreenTouch
	var is_drag_event = event is InputEventScreenDrag
	
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) or is_touch_event:
		if event.is_pressed():
			start_position = get_local_mouse_position()
			is_dragging = true
			# 检测当前在哪个card 上面
			for child in get_children():
				if child.get_rect().has_point(get_local_mouse_position()):
					child.z_index = 2
					cur_card.target = child
					cur_card.s_pos = child.position
					break
			# 防止事件冒泡
			get_viewport().set_input_as_handled()
		elif is_dragging:  # 松开手指/鼠标
			is_dragging = false
			if cur_card.target:
				cur_card.target.z_index = 1
				cur_card.s_pos = Vector2.ZERO
				cur_card.target._check_boundary()
				cur_card.target = null
			get_viewport().set_input_as_handled()
	
	elif (event is InputEventMouseMotion or is_drag_event) and is_dragging:
		# get_global_mouse_position 获取鼠标/触摸点相对于游戏窗口左上角的全局坐标
		# get_global_transform().get_scale() 获取控件当前的全局缩放比例
		var drag_offset = start_position - get_local_mouse_position()
		var target_pos = cur_card.s_pos - drag_offset
		var move_pos = get_global_transform().affine_inverse() * target_pos
		if cur_card.target:
			cur_card.target.set_move_pos(target_pos)
			cur_card.target._check_boundary()
			
		get_viewport().set_input_as_handled()
