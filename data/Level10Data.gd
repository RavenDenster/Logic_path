extends Resource
class_name Level10Data

@export var level_name: String = "Level 10: Conditional Selector"
@export var available_gates: Array[String] = ["AND", "OR", "NOT"]
@export var input_values_a: Array[int] = [0,0,0,0,1,1,1,1]
@export var input_values_b: Array[int] = [0,0,1,1,0,0,1,1] 
@export var input_values_c: Array[int] = [0,1,0,1,0,1,0,1]
@export var expected_output: Array[int] = [0,1,0,1,0,0,1,1] # (A AND B) OR (NOT A AND C)
@export_multiline var theory_text: String = """Уровень 10: Условный селектор

Простыми словами: Это "умный переключатель", который выбирает один из двух вариантов в зависимости от условия.

Аналогия из жизни:

Если идет дождь (условие=A), берем зонт (вариант=B)

Если нет дождя (условие=NOT A), берем солнцезащитные очки (вариант=C)

A  B  C | Выход | Объяснение
--------|-------|------------
0  0  0 |   0   | Условие A=0 → берем C=0
0  0  1 |   1   | Условие A=0 → берем C=1  
0  1  0 |   0   | Условие A=0 → берем C=0
0  1  1 |   1   | Условие A=0 → берем C=1
1  0  0 |   0   | Условие A=1 → берем B=0
1  0  1 |   1   | Условие A=1 → берем B=1
1  1  0 |   1   | Условие A=1 → берем B=1
1  1  1 |   1   | Условие A=1 → берем B=1

Применение: Основной строительный блок для процессоров - реализует оператор if-else на аппаратном уровне.
"""
