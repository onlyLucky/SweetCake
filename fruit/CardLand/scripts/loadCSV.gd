extends Node

#class_name CardDatabase

var card_date :Dictionary = {}

func _ready() -> void:
	# 加载card 图鉴
	card_date = load_csv("res://resource/data/cards.csv")
	print("card_date",card_date)


# 加载 CSV 并转换为字典数组
func load_csv(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var data = {}
	if file:
		var headers = file.get_csv_line()  # 读取首行（列名）
		while not file.eof_reached():
			var line = file.get_csv_line()
			if line.size() == headers.size():
				var row = {}
				for i in range(headers.size()):
					row[headers[i]] = line[i]
				data[row.id] = row
		file.close()
	return data
