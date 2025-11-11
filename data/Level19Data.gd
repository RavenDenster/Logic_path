extends Resource
class_name Level19Data

@export var level_name: String = "Level 19: 1-bit Comparator"
@export var available_gates: Array[String] = ["AND", "NOT", "XNOR"]
@export var input_values_a: Array[int] = [0,0,1,1]
@export var input_values_b: Array[int] = [0,1,0,1]
@export var expected_agtb: Array[int] = [0,0,1,0]  # A > B
@export var expected_altb: Array[int] = [0,1,0,0]  # A < B  
@export var expected_aeqb: Array[int] = [1,0,0,1]  # A == B
@export_multiline var theory_text: String = """[b]Уровень 19: 1-битный компаратор[/b]

Что это: Схема, которая сравнивает два однобитных числа A и B.

[b]Что делает:[/b] Определяет отношения между A и B и выдает три флага.

[b]Выходы:[/b]
• A>B = 1, если A больше B
• A<B = 1, если A меньше B  
• A==B = 1, если A равно B

[b]Таблица истинности:[/b]
A | B | A>B | A<B | A==B | Объяснение
0 | 0 |  0  |  0  |  1   | 0 = 0
0 | 1 |  0  |  1  |  0   | 0 < 1
1 | 0 |  1  |  0  |  0   | 1 > 0
1 | 1 |  0  |  0  |  1   | 1 = 1

[b]Логические формулы:[/b]
A>B = A AND NOT B
A<B = NOT A AND B  
A==B = A XNOR B (или NOT (A XOR B))

[b]Схема:[/b]

       |-------|
B -----| NOT   |----|       |
       |_______|    |       |
                    | AND 2 |---- A>B
A ------------------|_______|

       |-------|
A -----| NOT   |----|       |
       |_______|    |       |
                    | AND 1 |---- A<B
B ------------------|_______|

A -----|       |
       | XNOR  |---- A==B
B -----|_______|

[b]Что нужно для решения уровня:[/b]
• A<B: Инвертировать A → соединить с B через AND
• A>B: Инвертировать B → соединить с A через AND  
• A==B: Соединить A и B через XNOR

[b]Задача:[/b] Создайте 1-битный компаратор используя AND, NOT и XNOR вентили.
"""
