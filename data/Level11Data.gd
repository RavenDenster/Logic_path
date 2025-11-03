extends Resource
class_name Level11Data

@export var level_name: String = "Level 11: Pattern Detector"
@export var available_gates: Array[String] = ["AND", "OR", "NOT"]
@export var input_values_a: Array[int] = [0,0,0,0,1,1,1,1]
@export var input_values_b: Array[int] = [0,0,1,1,0,0,1,1]
@export var input_values_c: Array[int] = [0,1,0,1,0,1,0,1]
@export var expected_output: Array[int] = [1,0,0,0,0,1,0,0] # (NOT A AND NOT B AND NOT C) OR (A AND NOT B AND C)
@export_multiline var theory_text: String = """[b]Уровень 11: Детектор паттерна[/b]

Эта схема распознает две конкретные комбинации входных сигналов:

[b]Комбинация 1:[/b] A=0, B=0, C=0 → Выход=1
[b]Комбинация 2:[/b] A=1, B=0, C=1 → Выход=1

Для всех остальных комбинаций выход равен 0.

[b]Таблица истинности:[/b]
A | B | C | Выход | Объяснение
0 | 0 | 0 |   1   | Распознана первая комбинация
0 | 0 | 1 |   0   | Не распознано
0 | 1 | 0 |   0   | Не распознано  
0 | 1 | 1 |   0   | Не распознано
1 | 0 | 0 |   0   | Не распознано
1 | 0 | 1 |   1   | Распознана вторая комбинация
1 | 1 | 0 |   0   | Не распознано
1 | 1 | 1 |   0   | Не распознано
 
[b]Логическая формула:[/b]
(NOT A AND NOT B AND NOT C) OR (A AND NOT B AND C)

[b]Применение:[/b]
• Системы безопасности (распознавание "подозрительных" комбинаций)
• Сетевые устройства (поиск определенных последовательностей данных)
• Обработка сигналов и изображений

[b]Как решить:[/b]
1. Создайте первую часть: NOT A AND NOT B AND NOT C
2. Создайте вторую часть: A AND NOT B AND C  
3. Объедините результаты через OR
"""
