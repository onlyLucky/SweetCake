class_name DamageReceiver
extends Area2D

# 伤害的类型 普通攻击 击倒 大招
enum HitType {NORMAL, KNOCKDOWN, POWER}

signal damage_receiver(damage: int,direction: Vector2,hit_type: HitType)
