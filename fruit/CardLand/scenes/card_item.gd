extends Control

#class_name CardItemDarg

# 升级文字颜色值
const SexLv = ["#ffb1a4","#b3cdff"]
const SexBar = ["#ff9281","6e9eff"]

# 配置参数
@export var spring_stiffness := 0.2 #反弹力度
@export var damping := 0.5

@onready var card_con: Panel = $CardCon


var is_dragging := false
var velocity := Vector2.ZERO
var start_position := Vector2()
var boundary_rect := Rect2()
var drag_offset := Vector2.ZERO #点击位置偏移


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("_ready_ready")
	start_position = position
	boundary_rect = Rect2(Vector2(0,0), get_parent().size)
	
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
			z_index = 0
			_check_boundary()
			get_viewport().set_input_as_handled()
	
	elif (event is InputEventMouseMotion or is_drag_event) and is_dragging:
		# get_global_mouse_position 获取鼠标/触摸点相对于游戏窗口左上角的全局坐标
		# get_global_transform().get_scale() 获取控件当前的全局缩放比例
		var target_pos = get_global_mouse_position() - drag_offset * get_global_transform().get_scale()
		position = get_parent().get_global_transform().affine_inverse() * target_pos
		_check_boundary()
		get_viewport().set_input_as_handled()
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _check_boundary():
	# encloses 严格完全包含检测（不允许任何部分超出）
	# 类似于子场景加载 size 为0， 内部设置size也无效 节点树获取的是外部的
	if !boundary_rect.encloses(Rect2(position, card_con.size)):
		modulate = Color(1, 0.8, 0.8) # 越界红色提示
	else:
		modulate = Color.WHITE
	
	
