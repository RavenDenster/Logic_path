extends Resource
class_name Level7Data

@export var level_name: String = "Level 7: XNOR Gate"
@export var available_gates: Array[String] = ["AND", "OR", "NOT"]
@export var input_values_a: Array[int] = [0, 0, 1, 1]
@export var input_values_b: Array[int] = [0, 1, 0, 1]
@export var expected_output: Array[int] = [1, 0, 0, 1]
@export_multiline var theory_text: String = """
[b]Уровень 7: Логический элемент XNOR (эквиваленция)[/b]

XNOR возвращает 1, если входы одинаковые.

[b]Таблица истинности XNOR:[/b]
A | B | Результат
0 | 0 | 1
0 | 1 | 0
1 | 0 | 0
1 | 1 | 1

[b]Математическое выражение:[/b]
XNOR(A, B) = (A AND B) OR (NOT A AND NOT B)
или
XNOR(A, B) = NOT(XOR(A, B))

[b]Объяснение:[/b]
- XNOR означает "исключающее НЕ-ИЛИ"
- Результат 1 когда входы ОДИНАКОВЫЕ
- Результат 0 когда входы РАЗНЫЕ
- XNOR противоположен XOR

[b]Задача:[/b] Создайте XNOR схему используя доступные элементы.
[b]Подсказка:[/b] Можно реализовать как NOT(XOR), или напрямую по формуле.
"""
