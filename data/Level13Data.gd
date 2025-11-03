extends Resource
class_name Level13Data

@export var level_name: String = "Level 13: Half Adder"
@export var available_gates: Array[String] = ["AND", "XOR"]
@export var input_values_a: Array[int] = [0,0,1,1]
@export var input_values_b: Array[int] = [0,1,0,1]
@export var expected_sum: Array[int] = [0,1,1,0]
@export var expected_carry: Array[int] = [0,0,0,1]
@export_multiline var theory_text: String = """[b]Уровень 13: Полусумматор (Half Adder)[/b]

Простейшая схема для сложения двух битов.

[b]Что делает:[/b]
Вычисляет сумму двух битов A и B.

[b]Выходы:[/b]
• Sum (сумма) - младший бит результата
• Carry (перенос) - старший бит результата

[b]Таблица истинности:[/b]
A | B | Sum | Carry | Объяснение (A + B)
0 | 0 |  0  |   0   | 0 + 0 = 0 (0)
0 | 1 |  1  |   0   | 0 + 1 = 1 (1)  
1 | 0 |  1  |   0   | 1 + 0 = 1 (1)
1 | 1 |  0  |   1   | 1 + 1 = 2 (10 в двоичной)

[b]Логические формулы:[/b]
Sum = A XOR B
Carry = A AND B

[b]Схема:[/b]
A -----|       |
       | XOR   |---- Sum
B -----|_______|

A -----|       |
       | AND   |---- Carry
B -----|_______|

[b]Задача:[/b] Создайте полусумматор используя XOR и AND вентили.
"""
