extends Resource
class_name Level4Data

@export var level_name: String = "Level 4: NOR Gate (NOT + OR)"
@export var available_gates: Array[String] = ["OR", "NOT"]
@export var input_values_a: Array[int] = [0,0,1,1]
@export var input_values_b: Array[int] = [0,1,0,1]
@export var expected_output: Array[int] = [1,0,0,0]
@export_multiline var theory_text: String = """
[b]Уровень 4: Комбинация NOT + OR (NOR)[/b]

Элемент NOR возвращает 1, только если [b]оба[/b] входа равны 0.

[b]Таблица истинности NOR:[/b]
A | B | Результат
0 | 0 | 1
0 | 1 | 0
1 | 0 | 0
1 | 1 | 0

[b]Как создать NOR:[/b]
1. Добавьте элемент OR и элемент NOT
2. Соедините выход OR со входом NOT
3. Выход NOT будет выходом всей схемы (NOR)

[b]Логическая формула:[/b]
NOR(A, B) = NOT(OR(A, B))

[b]Применение:[/b] NOR - универсальный элемент, из которого можно построить любую логическую схему.
"""
