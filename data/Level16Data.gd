extends Resource
class_name Level16Data

@export var level_name: String = "Level 16: Half Subtractor"
@export var available_gates: Array[String] = ["XOR", "NOT", "AND"]
@export var input_values_a: Array[int] = [0,0,1,1]
@export var input_values_b: Array[int] = [0,1,0,1]
@export var expected_sum: Array[int] = [0,1,1,0]  # Difference
@export var expected_carry: Array[int] = [0,1,0,0]  # Borrow
@export_multiline var theory_text: String = """
[b]Уровень 16: Полувычитатель (Half Subtractor)[/b]

Полувычитатель - это логическая схема, выполняющая вычитание двух одноразрядных двоичных чисел.

[b]Принцип работы:[/b]

Полувычитатель имеет два входа (A и B) и два выхода (Difference и Borrow). Он вычисляет разность двух битов, где:
- Difference (разность) представляет результат вычитания
- Borrow (заем) указывает, нужно ли занять из старшего разряда

[b]Таблица истинности полувычитателя:[/b]

| A | B | Difference | Borrow |
|--------|--------|------------|--------|
|   0    |   0    |     0      |    0   |
|   0    |   1    |     1      |    1   |
|   1    |   0    |     1      |    0   |
|   1    |   1    |     0      |    0   |

[b]Объяснение:[/b]

Представьте вычитание двух однозначных двоичных чисел:
- 0 - 0 = 0 (Difference=0, Borrow=0)
- 0 - 1 = требует заема (Difference=1, Borrow=1)
- 1 - 0 = 1 (Difference=1, Borrow=0)
- 1 - 1 = 0 (Difference=0, Borrow=0)

Когда A < B, требуется заем из старшего разряда, что отражается в значении Borrow=1.

[b]Области применения:[/b]
- Арифметико-логические устройства (АЛУ) процессоров
- Цифровые системы обработки сигналов
- Схемы сравнения чисел
- Базовый блок для построения полных вычитателей

На этом уровне вам предстоит создать полувычитатель - фундаментальный строительный блок компьютерной арифметики для операций вычитания!

"""
