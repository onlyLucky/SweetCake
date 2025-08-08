class_name EnemySlot
extends Node2D

# 槽位引用实例化对象
var occupant: BasicEnemy = null

# 判断槽位是否被释放
func is_free() -> bool:
	return occupant == null

# 释放插槽位敌人
func free_up() -> void:
	occupant = null

# 设置插槽敌人
func occupy(enemy: BasicEnemy) -> void:
	occupant = enemy
