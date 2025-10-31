extends Resource
class_name Level9Data

@export var level_name: String = "Level 9: Arbitrary Function"
@export var available_gates: Array[String] = ["AND", "OR", "NOT"]
@export var input_values_a: Array[int] = [0,0,0,0,1,1,1,1]
@export var input_values_b: Array[int] = [0,0,1,1,0,0,1,1] 
@export var input_values_c: Array[int] = [0,1,0,1,0,1,0,1]
@export var expected_output: Array[int] = [1,0,0,0,0,0,1,0] # (NOT A AND NOT B AND NOT C) OR (A AND B AND NOT C)
@export_multiline var theory_text: String = """Уровень 9: Произвольная функция трех переменных

Цель: Применить все полученные навыки для решения незнакомой задачи.

Таблица истинности:
A  B  C | Выход
--------|------
0  0  0 |   1
0  0  1 |   0
0  1  0 |   0
0  1  1 |   1
1  0  0 |   0
1  0  1 |   1
1  1  0 |   1
1  1  1 |   0

Доступные элементы: 2 элемента AND, 1 элемент OR, 2 элемента NOT.

Задача: Проанализируйте таблицу истинности и найдите логическую формулу, которая описывает эту функцию.

Подсказки:
- Обратите внимание, когда выход равен 1
- Попробуйте сгруппировать случаи с единичным выходом
- Используйте элементы NOT для инвертирования входов
- Комбинируйте элементы AND и OR для создания нужной логики

Это уровень-головоломка, развивающий навык синтеза схем по таблице истинности!"""
