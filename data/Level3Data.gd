extends Resource
class_name Level3Data

@export var level_name: String = "Level 3: NAND Gate"
@export var available_gates: Array[String] = ["AND", "NOT"]
@export var input_values_a: Array[int] = [0, 0, 1, 1]
@export var input_values_b: Array[int] = [0, 1, 0, 1]
@export var expected_output: Array[int] = [1, 1, 1, 0]
@export_multiline var theory_text: String = """
[b]Уровень 3: Логический элемент NAND (И-НЕ)[/b]

NAND - это AND с инвертированным выходом. 
Возвращает 0, только если оба входа равны 1.

[b]Таблица истинности NAND:[/b]
A | B | Результат
0 | 0 | 1
0 | 1 | 1  
1 | 0 | 1
1 | 1 | 0

[b]Математическое выражение:[/b]
NAND(A, B) = NOT(AND(A, B))

[b]Объяснение:[/b]
- NAND противоположен AND
- Результат 0 только в одном случае: A=1 и B=1
- Во всех остальных случаях результат 1

[b]Задача:[/b] Создайте NAND используя комбинацию AND и NOT.
"""
