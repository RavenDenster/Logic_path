# Level23Data.gd
extends Resource
class_name Level23Data

@export var level_name: String = "Level 23: 2→4 Decoder"
@export var available_gates: Array[String] = ["AND", "NOT"]
@export var input_values_a: Array[int] = [0,0,1,1]
@export var input_values_b: Array[int] = [0,1,0,1]

# Ожидаемые значения для выходов Y0-Y3
@export var expected_y0: Array[int] = [1,0,0,0]  # Y0 = NOT A AND NOT B
@export var expected_y1: Array[int] = [0,1,0,0]  # Y1 = NOT A AND B
@export var expected_y2: Array[int] = [0,0,1,0]  # Y2 = A AND NOT B
@export var expected_y3: Array[int] = [0,0,0,1]  # Y3 = A AND B

@export_multiline var theory_text: String = """[b]Уровень 23: Дешифратор 2→4[/b]

Что это: Схема, которая преобразует 2-битный двоичный код в унарный код (активирует один из четырех выходов).

[b]Принцип работы:[/b] Каждая комбинация входов A и B активирует соответствующий выход Y0-Y3.

[b]Таблица истинности:[/b]

A  B | Y3 Y2 Y1 Y0 | Активный выход | Двоичный вход
-----|-------------|---------------|--------------
0  0 | 0  0  0  1  | Y0            | 00
0  1 | 0  0  1  0  | Y1            | 01  
1  0 | 0  1  0  0  | Y2            | 10
1  1 | 1  0  0  0  | Y3            | 11

[b]Логические формулы:[/b]

Y0 = NOT A AND NOT B

Y1 = NOT A AND B

Y2 = A AND NOT B

Y3 = A AND B

[b]Схема решения:[/b]

A --|       |          |-------|
    | NOT   |----------|       |
B --|_______|          | AND 0 |---- Y0
    |       |          |_______|
B --| NOT   |----------|
    |_______|          |-------|
                       | AND 1 |---- Y1
A ---------------------|_______|

A ---------------------|-------|
                       | AND 2 |---- Y2
B --|       |          |_______|
    | NOT   |----------|
    |_______|          |-------|
                       | AND 3 |---- Y3
B ---------------------|_______|

[b]Что нужно сделать:[/b]

1. Создать инвертированные сигналы A и B (используя 2 элемента NOT)

2. Для каждого выхода использовать элемент AND с соответствующими комбинациями:

   • Y0: NOT A AND NOT B
   • Y1: NOT A AND B  
   • Y2: A AND NOT B
   • Y3: A AND B

[b]Задача:[/b] Создайте дешифратор 2→4 используя NOT и AND вентили.
"""
