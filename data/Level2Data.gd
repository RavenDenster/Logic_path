extends Resource
class_name Level2Data

@export var level_name: String = "Level 2"
@export var available_gates: Array[String] = ["AND"]
@export var input_values_a: Array[int] = [0, 1, 1, 1]
@export var input_values_b: Array[int] = [0, 1, 0, 1]
@export var expected_output: Array[int] = [0, 1, 0, 1]
@export_multiline var theory_text: String = """
[b]Уровень 2: Логический элемент AND (И)[/b]

Элемент AND возвращает 1, только если [b]оба[/b] входа равны 1.

[b]Таблица истинности AND:[/b]
A | B | Результат
0 | 0 | 0
0 | 1 | 0
1 | 0 | 0
1 | 1 | 1

[b]Объяснение:[/b]
- Если A=0 и B=0 → результат 0
- Если A=0 и B=1 → результат 0  
- Если A=1 и B=0 → результат 0
- Если A=1 и B=1 → результат 1

[b]Задача:[/b] Создайте схему с элементом AND, которая дает 1 только когда оба входа равны 1.
"""
