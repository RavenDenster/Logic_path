extends Resource
class_name Level7Data

@export var level_name: String = "Level 7: Majority Gate"
@export var available_gates: Array[String] = ["AND", "OR"]
@export var input_values_a: Array[int] = [0,0,0,0,1,1,1,1]
@export var input_values_b: Array[int] = [0,0,1,1,0,0,1,1] 
@export var input_values_c: Array[int] = [0,1,0,1,0,1,0,1]
@export var expected_output: Array[int] = [0,0,0,1,0,1,1,1]
@export_multiline var theory_text: String = """Мажоритарный элемент (правило большинства)

Цель: Построить схему, которая возвращает 1, если большинство входов (2 или 3 из 3) равны 1.

Формула: (A AND B) OR (A AND C) OR (B AND C)

Таблица истинности для трех входов A, B, C:
A  B  C | Выход
--------|------
0  0  0 |   0
0  0  1 |   0  
0  1  0 |   0
0  1  1 |   1  (B и C = 1)
1  0  0 |   0
1  0  1 |   1  (A и C = 1)
1  1  0 |   1  (A и B = 1)
1  1  1 |   1  (A, B и C = 1)

Для решения используйте:
- 3 элемента AND для проверки пар (A,B), (A,C), (B,C)
- 1 элемент OR для объединения результатов

Совет: Соедините выходы трех AND-элементов с входами OR-элемента."""
