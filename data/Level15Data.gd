extends Resource
class_name Level15Data

@export var level_name: String = "Level 15: 2-Bit Adder"
@export var available_gates: Array[String] = ["HalfAdder", "FullAdder", "Cout0"]
@export var input_values_a1: Array[int] = [0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]
@export var input_values_a0: Array[int] = [0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1]
@export var input_values_b1: Array[int] = [0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1]
@export var input_values_b0: Array[int] = [0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1]
@export var expected_s1: Array[int] = [0,0,1,1,0,1,1,0,1,1,0,0,1,0,0,1]
@export var expected_s0: Array[int] = [0,1,0,1,1,0,1,0,0,1,0,1,1,0,1,0]
@export var expected_cout: Array[int] = [0,0,0,0,0,0,0,1,0,0,1,1,0,1,1,1]
@export_multiline var theory_text: String = """[b]Уровень 15: 2-битный сумматор (2-Bit Adder)[/b]

Схема для сложения двух 2-битных чисел.

[b]Что делает:[/b]
Складывает числа A (A1,A0) и B (B1,B0), где A1,B1 - старшие биты.

[b]Выходы:[/b]
• S1,S0 - 2-битный результат
• Cout - перенос (для 3-го разряда)

[b]Принцип работы:[/b]
  A1 A0  (например: A=10 → A1=1, A0=0)
+ B1 B0  (например: B=11 → B1=1, B0=1)
--------
 C1 S1 S0 (результат: 101 → C1=1, S1=0, S0=1)

[b]Схема:[/b]
A0 -----|               |
B0 -----| Полусумматор  |---- S0
        | 1             |---- Cout0
        |_______________|

A1 -----|               |
B1 -----| Полный        |---- S1
Cout0 --| сумматор      |---- Cout
        |_______________|

[b]Что нужно для решения уровня:[/b]
• Взять первый полусумматор
• Подать на него A0, B0 → получаем S0 и промежуточный перенос Cout0
• Взять второй полный сумматор
• Подать на него A1, B1 и перенос Cout0 → получаем S1 и Cout

[b]Задача:[/b] Создайте 2-битный сумматор используя полусумматор и полный сумматор.
"""
