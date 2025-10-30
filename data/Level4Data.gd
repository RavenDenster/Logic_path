extends Resource
class_name Level4Data

@export var level_name: String = "Level 4: XOR Gate"
@export var available_gates: Array[String] = ["AND", "OR", "NOT"]
@export var input_values_a: Array[int] = [0, 0, 1, 1]
@export var input_values_b: Array[int] = [0, 1, 0, 1]
@export var expected_output: Array[int] = [0, 1, 1, 0]
@export_multiline var theory_text: String = """
[b]Уровень 4: Логический элемент XOR (исключающее ИЛИ)[/b]

XOR возвращает 1, если входы разные.

[b]Таблица истинности XOR:[/b]
A | B | Результат
0 | 0 | 0
0 | 1 | 1
1 | 0 | 1
1 | 1 | 0

[b]Математическое выражение:[/b]
XOR(A, B) = (A AND NOT B) OR (NOT A AND B)

[b]Объяснение:[/b]
- XOR означает "исключающее ИЛИ"
- Результат 1 когда входы РАЗНЫЕ
- Результат 0 когда входы ОДИНАКОВЫЕ

[b]Задача:[/b] Соберите XOR используя доступные элементы (AND, OR, NOT).
[b]Подсказка:[/b] Вам понадобятся 2 элемента AND, 2 элемента NOT и 1 элемент OR.
"""
