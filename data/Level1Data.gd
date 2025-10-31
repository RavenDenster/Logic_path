extends Resource
class_name Level1Data

@export var level_name: String = "Level 1"
@export var available_gates: Array[String] = ["OR"]
@export var input_config: String = "dual"
@export var input_values_a: Array[int] = [0, 0, 1, 1]
@export var input_values_b: Array[int] = [0, 1, 0, 1]
@export var expected_output: Array[int] = [0, 1, 1, 1]
@export_multiline var theory_text: String = """
[b]Уровень 1: Логический элемент OR (ИЛИ)[/b]

Элемент OR возвращает 1, если [b]хотя бы один[/b] из входов равен 1.

[b]Таблица истинности OR:[/b]
A | B | Результат
0 | 0 | 0
0 | 1 | 1
1 | 0 | 1
1 | 1 | 1

[b]Как играть:[/b]
• Перетаскивайте элементы из верхней панели
• Соединяйте элементы проводами (левая кнопка мыши)
• Нажмите RUN для проверки схемы
• Удаление: правый клик на элементе или проводе
• Ваша задача: создать схему, которая соответствует таблице истинности OR

[b]Подсказка:[/b] Просто используйте один элемент OR и подключите к нему оба входа.
"""
