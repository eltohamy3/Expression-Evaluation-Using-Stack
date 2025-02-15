# Expression Evaluation Using Stack (MIPS Assembly)

## 📌 Overview
This project implements an **Expression Evaluation System** in **MIPS Assembly**, allowing the conversion of infix expressions to postfix notation and evaluating the final result. The program efficiently handles **addition, subtraction, multiplication, division, exponentiation, and parentheses** using **stack-based processing**.

## 🚀 Features
- **Infix to Postfix Conversion** using the **Shunting Yard Algorithm**.
- **Postfix Expression Evaluation** to compute the final result.
- **Supports multiple operators**: `+`, `-`, `*`, `/`, `^`, and parentheses `()`. 
- **Handles operator precedence** and **associativity**.
- **Stack implementation** using MIPS Assembly.
- **Optimized for low-level processing**.

## 🛠 Technologies Used
- **MIPS Assembly Language**
- **SPIM / MARS Simulator** for execution
- **Stack Data Structure** for expression processing

## 📂 Project Structure
```
📁 Expression-Evaluation-Using-Stack
 ┣ 📜 expression_eval.asm   # MIPS Assembly Code
 ┣ 📜 README.md              # Project Documentation
 ┣ 📜 test_cases.txt         # Sample Expressions
```

## 🔧 Installation & Setup
1. Download and install **MARS** or **SPIM** MIPS simulator.
2. Clone the repository:
   ```sh
   git clone https://github.com/eltohamy3/Expression-Evaluation-Using-Stack.git
   ```
3. Open `expression_eval.asm` in **MARS**.
4. Assemble and run the program.

## 📝 Usage
1. Enter a valid infix expression (e.g., `3 + 5 * (2 ^ 3)`).
2. The program converts it to postfix notation.
3. The final result is calculated and displayed.

## 🏆 Example
### Input:
```
(3 + 5) * 2 ^ 3 - 10 / 2
```
### Postfix Conversion:
```
3 5 + 2 3 ^ * 10 2 / -
```
### Output:
```
54
```

## 📜 License
This project is **open-source** and available under the [MIT License](LICENSE).

## 👤 Author
**Abdelrahman Mahmoud Mohamed Elothamy**
- GitHub: [eltohamy3](https://github.com/eltohamy3)

Feel free to contribute, report issues, or suggest improvements! 🚀
