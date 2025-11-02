extends Resource
class_name Level12Data

@export var level_name: String = "Level 12: 3-input Multiplexer"
@export var available_gates: Array[String] = ["AND", "OR", "NOT", "SEL0", "SEL1"]
@export var input_values_a: Array[int] = [0,0,0,0,1,1,1,1]   # Data0
@export var input_values_b: Array[int] = [0,0,1,1,0,0,1,1]   # Data1  
@export var input_values_c: Array[int] = [0,1,0,1,0,1,0,1]   # Data2
@export var expected_output: Array[int] = [0,1,1,0,0,0,1,1]  # ИСПРАВЛЕННЫЕ ожидаемые результаты
@export_multiline var theory_text: String = """
[b]Уровень 12: Трехвходовый мультиплексор (3-input Multiplexer)[/b]

Простыми словами: Это "многопозиционный переключатель" с тремя входами данных и двумя управляющими сигналами.

[b]Аналогия из жизни:[/b]
Селектор каналов на телевизоре с 3 каналами:
- Канал 0 (Data0)
- Канал 1 (Data1) 
- Канал 2 (Data2)
Переключатель (Sel) выбирает какой канал смотреть

[b]Управляющие сигналы:[/b]
Sel1 | Sel0 | Выбранный вход
-----|------|---------------
  0  |  0   | Data0
  0  |  1   | Data1
  1  |  0   | Data2
  1  |  1   | 0 (не используется)

[b]Таблица истинности для 8 тестов:[/b]
Test | Data0 | Data1 | Data2 | Sel1 | Sel0 | Output | Объяснение
-----|-------|-------|-------|------|------|--------|-----------
  0  |   0   |   0   |   0   |  0   |  0   |   0    | Sel=00 → Data0=0
  1  |   0   |   0   |   1   |  0   |  1   |   0    | Sel=01 → Data1=0  
  2  |   0   |   1   |   0   |  1   |  0   |   0    | Sel=10 → Data2=0
  3  |   0   |   1   |   1   |  0   |  0   |   0    | Sel=00 → Data0=0
  4  |   1   |   0   |   0   |  0   |  1   |   0    | Sel=01 → Data1=0
  5  |   1   |   0   |   1   |  1   |  0   |   1    | Sel=10 → Data2=1
  6  |   1   |   1   |   0   |  0   |  0   |   1    | Sel=00 → Data0=1
  7  |   1   |   1   |   1   |  0   |  1   |   1    | Sel=01 → Data1=1

[b]Логическая формула:[/b]
Output = (Data0 AND NOT Sel1 AND NOT Sel0) OR 
         (Data1 AND NOT Sel1 AND Sel0) OR 
         (Data2 AND Sel1 AND NOT Sel0)

[b]Применение:[/b] Основной строительный блок для процессоров - реализует оператор if-else на аппаратном уровне.
"""
