extends Control

var is_dragging := false
var start_position := Vector2()
var drag_offset := Vector2.ZERO #点击位置偏移

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
			drag_offset = get_local_mouse_position()
			is_dragging = true
			# 防止事件冒泡
			get_viewport().set_input_as_handled()
		elif is_dragging:  # 松开手指/鼠标
			is_dragging = false
			#z_index = 0
			#_check_boundary()
			get_viewport().set_input_as_handled()
	
	elif (event is InputEventMouseMotion or is_drag_event) and is_dragging:
		# get_global_mouse_position 获取鼠标/触摸点相对于游戏窗口左上角的全局坐标
		# get_global_transform().get_scale() 获取控件当前的全局缩放比例
		#if card_con.get_rect().has_point(get_local_mouse_position()):
		var target_pos = get_global_mouse_position() - drag_offset * get_global_transform().get_scale()
		#position = get_parent().get_global_transform().affine_inverse() * target_pos
		#_check_boundary()
		print("drag card box")
			
		get_viewport().set_input_as_handled()
