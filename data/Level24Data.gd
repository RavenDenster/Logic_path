# Level24Data.gd
extends Resource
class_name Level24Data

@export var level_name: String = "Level 24: 3→8 Decoder"
@export var available_gates: Array[String] = ["AND", "NOT"]
@export var input_values_a: Array[int] = [0,0,0,0,1,1,1,1]
@export var input_values_b: Array[int] = [0,0,1,1,0,0,1,1]
@export var input_values_c: Array[int] = [0,1,0,1,0,1,0,1]

# Ожидаемые значения для выходов Y0-Y7
@export var expected_y0: Array[int] = [1,0,0,0,0,0,0,0]  # Y0 = NOT A AND NOT B AND NOT C
@export var expected_y1: Array[int] = [0,1,0,0,0,0,0,0]  # Y1 = NOT A AND NOT B AND C
@export var expected_y2: Array[int] = [0,0,1,0,0,0,0,0]  # Y2 = NOT A AND B AND NOT C
@export var expected_y3: Array[int] = [0,0,0,1,0,0,0,0]  # Y3 = NOT A AND B AND C
@export var expected_y4: Array[int] = [0,0,0,0,1,0,0,0]  # Y4 = A AND NOT B AND NOT C
@export var expected_y5: Array[int] = [0,0,0,0,0,1,0,0]  # Y5 = A AND NOT B AND C
@export var expected_y6: Array[int] = [0,0,0,0,0,0,1,0]  # Y6 = A AND B AND NOT C
@export var expected_y7: Array[int] = [0,0,0,0,0,0,0,1]  # Y7 = A AND B AND C

@export_multiline var theory_text: String = """[b]Уровень 24: Дешифратор 3→8[/b]

Что это: Схема, которая преобразует 3-битный двоичный код в унарный код (активирует один из восьми выходов).

[b]Принцип работы:[/b] Каждая комбинация входов A, B, C активирует соответствующий выход Y0-Y7.

[b]Таблица истинности:[/b]

A  B  C | Y7 Y6 Y5 Y4 Y3 Y2 Y1 Y0 | Активный выход
--------|-------------------------|---------------
0  0  0 | 0  0  0  0  0  0  0  1  | Y0
0  0  1 | 0  0  0  0  0  0  1  0  | Y1
0  1  0 | 0  0  0  0  0  1  0  0  | Y2
0  1  1 | 0  0  0  0  1  0  0  0  | Y3
1  0  0 | 0  0  0  1  0  0  0  0  | Y4
1  0  1 | 0  0  1  0  0  0  0  0  | Y5
1  1  0 | 0  1  0  0  0  0  0  0  | Y6
1  1  1 | 1  0  0  0  0  0  0  0  | Y7

[b]Логические формулы:[/b]

Y0 = NOT A AND NOT B AND NOT C

Y1 = NOT A AND NOT B AND C

Y2 = NOT A AND B AND NOT C

Y3 = NOT A AND B AND C

Y4 = A AND NOT B AND NOT C

Y5 = A AND NOT B AND C

Y6 = A AND B AND NOT C

Y7 = A AND B AND C

[b]Схема решения:[/b]

A --|       |
    | NOT   |--|       |
B --|_______|  |       |
    |       |  | AND 0 |---- Y0
B --| NOT   |--|       |
    |_______|  |_______|
C --|       |
    | NOT   |--|
    |_______|

... и так для всех 8 выходов

[b]Что нужно сделать:[/b]

1. Создать инвертированные сигналы A, B, C (используя 3 элемента NOT)

2. Для каждого выхода Y0-Y7 использовать элемент AND с тремя входами:

   • Y0: NOT A, NOT B, NOT C
   • Y1: NOT A, NOT B, C
   • Y2: NOT A, B, NOT C
   • Y3: NOT A, B, C
   • Y4: A, NOT B, NOT C
   • Y5: A, NOT B, C
   • Y6: A, B, NOT C
   • Y7: A, B, C

[b]Задача:[/b] Создайте дешифратор 3→8 используя NOT и AND вентили.
"""
