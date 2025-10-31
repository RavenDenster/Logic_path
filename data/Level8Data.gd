extends Resource
class_name Level8Data

@export var level_name: String = "Level 8: Parity Check (XOR Cascade)"
@export var available_gates: Array[String] = ["XOR"]
@export var input_values_a: Array[int] = [0,0,0,0,1,1,1,1]
@export var input_values_b: Array[int] = [0,0,1,1,0,0,1,1] 
@export var input_values_c: Array[int] = [0,1,0,1,0,1,0,1]
@export var expected_output: Array[int] = [0,1,1,0,1,0,0,1]
@export_multiline var theory_text: String = """Сумматор по модулю 2 (Функция чётности)

Цель: Построить схему, которая возвращает 1, если число единиц на входах нечётное.

Формула: A XOR B XOR C

Таблица истинности для трех входов A, B, C:
A  B  C | Выход
--------|------
0  0  0 |   0  (четное число 1)
0  0  1 |   1  (нечетное: одна 1)
0  1  0 |   1  (нечетное: одна 1)  
0  1  1 |   0  (четное: две 1)
1  0  0 |   1  (нечетное: одна 1)
1  0  1 |   0  (четное: две 1)
1  1  0 |   0  (четное: две 1)
1  1  1 |   1  (нечетное: три 1)

Концепция каскадирования:
- Первый XOR вычисляет A XOR B
- Второй XOR берёт результат первого и вычисляет (A XOR B) XOR C

Совет: 
1. Создайте первый XOR-элемент и подключите A и B
2. Создайте второй XOR-элемент и подключите:
   - Вход 1: выход первого XOR
   - Вход 2: вход C
3. Выход второго XOR подключите к OutputBlock

Это вводит важную концепцию каскадирования логических элементов!"""
