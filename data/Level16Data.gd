extends Resource
class_name Level16Data

@export var level_name: String = "Level 16: Half Subtractor"
@export var available_gates: Array[String] = ["XOR", "NOT", "AND"]
@export var input_values_a: Array[int] = [0,0,1,1]
@export var input_values_b: Array[int] = [0,1,0,1]
@export var expected_sum: Array[int] = [0,1,1,0]  # Difference
@export var expected_carry: Array[int] = [0,1,0,0]  # Borrow
@export_multiline var theory_text: String = """[b]Уровень 16: Полувычитатель (Half Subtractor)[/b]

Простейшая схема для вычитания двух битов.

[b]Что делает:[/b]
Вычисляет разность двух битов A и B (A - B).

[b]Выходы:[/b]
• Difference (разность) - результат вычитания
• Borrow (заем) - флаг, указывающий, что пришлось занять из старшего разряда

[b]Таблица истинности:[/b]
A | B | Difference | Borrow | Объяснение (A - B)
0 | 0 |     0     |   0    | 0 - 0 = 0
0 | 1 |     1     |   1    | 0 - 1 = 1 (с заемом)
1 | 0 |     1     |   0    | 1 - 0 = 1
1 | 1 |     0     |   0    | 1 - 1 = 0

[b]Логические формулы:[/b]
Difference = A XOR B
Borrow = NOT A AND B

[b]Схема:[/b]
A -----|       |
       | XOR   |---- Difference
B -----|_______|

A --|       |
    | NOT   |----|       |
B ----------| AND |---- Borrow
            |_______|

[b]Задача:[/b] Создайте полувычитатель используя XOR, NOT и AND вентили.
"""
