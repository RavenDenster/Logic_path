extends Resource
class_name Level5Data

@export var level_name: String = "Level 5: Implication"
@export var available_gates: Array[String] = ["OR", "NOT"]
@export var input_values_a: Array[int] = [0, 0, 1, 1]
@export var input_values_b: Array[int] = [0, 1, 0, 1]
@export var expected_output: Array[int] = [1, 1, 0, 1]
@export_multiline var theory_text: String = """
[b]Уровень 5: Импликация (логическое следствие)[/b]

Импликация A → B означает "если A, то B".
Ложь только когда A=1 и B=0.

[b]Таблица истинности Импликации:[/b]
A | B | Результат
0 | 0 | 1
0 | 1 | 1
1 | 0 | 0
1 | 1 | 1

[b]Математическое выражение:[/b]
A → B = NOT A OR B

[b]Объяснение:[/b]
- Импликация ложна только в одном случае: когда посылка истинна, а следствие ложно
- "Если идет дождь, то я беру зонт" - ложь только если дождь идет, а зонта нет
- Во всех остальных случаях импликация истинна

[b]Задача:[/b] Реализуйте импликацию используя OR и NOT.
"""
