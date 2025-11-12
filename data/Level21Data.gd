# Level21Data.gd
extends Resource
class_name Level21Data

@export var level_name: String = "Level 21: 4-to-2 Encoder"
@export var available_gates: Array[String] = ["OR"]
@export var input_values_i0: Array[int] = [1, 0, 0, 0]
@export var input_values_i1: Array[int] = [0, 1, 0, 0]
@export var input_values_i2: Array[int] = [0, 0, 1, 0]
@export var input_values_i3: Array[int] = [0, 0, 0, 1]
@export var expected_o0: Array[int] = [0, 1, 0, 1]
@export var expected_o1: Array[int] = [0, 0, 1, 1]

@export_multiline var theory_text: String = """[b]Уровень 21: Шифратор 4→2 (Encoder)[/b]

Что это: Схема, которая преобразует унарный код (один активный вход из четырех) в двоичный код (двухбитный номер активного входа).

[b]Принцип работы:[/b] Когда активен ровно один из входов I0-I3, шифратор выдает его двоичный номер.

[b]Таблица истинности:[/b]
I3 I2 I1 I0 | O1 O0 | Активный вход | Двоичный номер
------------|-------|---------------|--------------
0  0  0  1  | 0  0  | I0            | 00
0  0  1  0  | 0  1  | I1            | 01
0  1  0  0  | 1  0  | I2            | 10
1  0  0  0  | 1  1  | I3            | 11

[b]Логические формулы:[/b]
O1 = I2 OR I3 (старший бит номера)
O0 = I1 OR I3 (младший бит номера)

[b]Схема решения:[/b]
I2 -----|       |
        | OR 1  |---- O1
I3 -----|_______|

I1 -----|       |
        | OR 2  |---- O0
I3 -----|_______|

[b]Что нужно сделать:[/b]
• Соединить I2 и I3 с первым OR → получаем O1
• Соединить I1 и I3 со вторым OR → получаем O0

[b]Особенность:[/b] Предполагается, что активен ровно один вход. Если активны несколько, поведение не определено.

[b]Задача:[/b] Создайте шифратор 4→2 используя OR вентили.
"""
