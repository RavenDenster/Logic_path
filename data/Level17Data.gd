extends Resource
class_name Level17Data

@export var level_name: String = "Level 17: Full Subtractor"
@export var available_gates: Array[String] = ["XOR", "NOT", "AND", "OR"]
@export var input_values_a: Array[int] = [0,0,0,0,1,1,1,1]
@export var input_values_b: Array[int] = [0,0,1,1,0,0,1,1]
@export var input_values_cin: Array[int] = [0,1,0,1,0,1,0,1]
@export var expected_sum: Array[int] = [0,1,1,0,1,0,0,1]  # Difference
@export var expected_cout: Array[int] = [0,1,1,1,0,0,0,1]  # Bout
@export_multiline var theory_text: String = """[b]Уровень 17: Полный вычитатель (Full Subtractor)[/b]

Вычитатель, который учитывает заем из предыдущего разряда (Bin).

[b]Что делает:[/b]
Вычисляет A - B - Bin.

[b]Выходы:[/b]
• Difference - результат вычитания
• Bout (Borrow-out) - заем в следующий разряд

[b]Таблица истинности:[/b]
A | B | Bin | Difference | Bout | Объяснение (A - B - Bin)
0 | 0 |  0  |     0     |   0  | 0 - 0 - 0 = 0
0 | 0 |  1  |     1     |   1  | 0 - 0 - 1 = 1 (с заемом)
0 | 1 |  0  |     1     |   1  | 0 - 1 - 0 = 1 (с заемом)
0 | 1 |  1  |     0     |   1  | 0 - 1 - 1 = 0 (с двойным заемом)
1 | 0 |  0  |     1     |   0  | 1 - 0 - 0 = 1
1 | 0 |  1  |     0     |   0  | 1 - 0 - 1 = 0
1 | 1 |  0  |     0     |   0  | 1 - 1 - 0 = 0
1 | 1 |  1  |     1     |   1  | 1 - 1 - 1 = 1 (с заемом)

[b]Логические формулы:[/b]
Difference = A XOR B XOR Bin
Bout = (NOT A AND B) OR (NOT A AND Bin) OR (B AND Bin)

[b]Схема:[/b]
A -----|       |
       | XOR 1 |-----|       |
B -----|_______|     | XOR 2 |---- Difference
                     |_______|
Bin -----------------|

A --|       |   |       |
    | NOT   |---|       |
B ----------| AND 1 |   |       |
            |_______|   |       |
                        | OR    |---- Bout
A --|       |   |       |       |
    | NOT   |---|       |       |
Bin ---------| AND 2 |---|_______|
            |_______|

B ----------|       |   |
            | AND 3 |---|
Bin ---------|_______|

[b]Задача:[/b] Создайте полный вычитатель используя XOR, NOT, AND и OR вентили.
"""
