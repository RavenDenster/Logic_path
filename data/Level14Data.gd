extends Resource
class_name Level14Data

@export var level_name: String = "Level 14: Full Adder"
@export var available_gates: Array[String] = ["AND", "XOR", "OR"]
@export var input_values_a: Array[int] = [0,0,0,0,1,1,1,1]
@export var input_values_b: Array[int] = [0,0,1,1,0,0,1,1]
@export var input_values_cin: Array[int] = [0,1,0,1,0,1,0,1]
@export var expected_sum: Array[int] = [0,1,1,0,1,0,0,1]
@export var expected_cout: Array[int] = [0,0,0,1,0,1,1,1]
@export_multiline var theory_text: String = """[b]Уровень 14: Полный сумматор (Full Adder)[/b]

Схема для сложения трех битов: A, B и переноса Cin.

[b]Что делает:[/b]
Вычисляет сумму трех битов и перенос в следующий разряд.

[b]Выходы:[/b]
• Sum (сумма) - младший бит результата
• Cout (перенос) - старший бит результата

[b]Таблица истинности:[/b]
A | B | Cin | Sum | Cout | Объяснение (A + B + Cin)
--|---|-----|-----|------|-------------------------
0 | 0 |  0  |  0  |   0  | 0 + 0 + 0 = 0
0 | 0 |  1  |  1  |   0  | 0 + 0 + 1 = 1
0 | 1 |  0  |  1  |   0  | 0 + 1 + 0 = 1
0 | 1 |  1  |  0  |   1  | 0 + 1 + 1 = 2 (10)
1 | 0 |  0  |  1  |   0  | 1 + 0 + 0 = 1
1 | 0 |  1  |  0  |   1  | 1 + 0 + 1 = 2 (10)
1 | 1 |  0  |  0  |   1  | 1 + 1 + 0 = 2 (10)
1 | 1 |  1  |  1  |   1  | 1 + 1 + 1 = 3 (11)

[b]Логические формулы:[/b]
Sum = A XOR B XOR Cin
Cout = (A AND B) OR (Cin AND (A XOR B))

[b]Схема:[/b]
A -----|       |
       | XOR 1 |-----|       |
B -----|_______|     | XOR 2 |---- Sum
                     |_______|
Cin -----------------|

A -----|       |
       | AND 1 |-----|       |
B -----|_______|     |       |
                     | OR    |---- Cout
Cin -----|       |   |       |
         | AND 2 |-----|_______|
A --|       |   |
   | XOR 1 |---|
B --|_______|

[b]Задача:[/b] Создайте полный сумматор используя XOR, AND и OR вентили.
"""
