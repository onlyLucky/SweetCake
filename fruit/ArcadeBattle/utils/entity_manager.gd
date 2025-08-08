extends Node

## 生成可收集物
signal spawn_collectible(
	type: Collectible.Type,
	initial_state: Collectible.State,
	collectible_global_position: Vector2,
	collectible_direction: Vector2,
	initial_height: float
)
