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
var start_position := Vector2()
var boundary_rect := Rect2()
var drag_offset := Vector2.ZERO #点击位置偏移

var velocity := Vector2.ZERO  # 初始移动速度
var bounce_factor := 0.8  # 回弹衰减系数 (0~1)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = position
	boundary_rect = Rect2(Vector2(0,0), get_parent().size)

func _process(delta):
	# todo 回弹效果监测 进行加速度处理
	pass

# 添加弹性动画效果 
func add_bounce_effect():
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.5).from(Vector2(0.9, 1.1))
	
	
# 设置位移
func set_move_pos(pos: Vector2):
	position = pos

# 检测边缘
func _check_boundary():
	# encloses 严格完全包含检测（不允许任何部分超出）
	# 类似于子场景加载 size 为0， 内部设置size也无效 节点树获取的是外部的
	if !boundary_rect.encloses(Rect2(position, card_con.size)):
		modulate = Color(1, 0.8, 0.8) # 越界红色提示
	else:
		modulate = Color.WHITE
	
	
