class_name DamageReceiver
extends Area2D

## 伤害的类型 
enum HitType {
	## 普通攻击
	NORMAL,
	## 击倒
	KNOCKDOWN, 
	## 大招
	POWER
}

## 伤害接收器 
## damage 伤害值
signal damage_receiver(damage: int,direction: Vector2,hit_type: HitType)
