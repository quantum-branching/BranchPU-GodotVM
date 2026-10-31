# Instruction Set Architecture (ISA) Reference

This ISA defines a simple accumulator-based CPU with unsigned, 8-bit, modulo-256 arithmetic.

All registers and the accumulator are **unsigned 8-bit values**.  
All arithmetic operations **wrap modulo 256**.

## Registers and State

* **Accumulator (A)**: Implicit operand/result register
* **General-purpose registers**: Indexed by immediate values
* **Program Counter (PC)**: Points to the current instruction
* **Comparison Flag (CF)**: Set by `CMP`, used by `CND`
* **Stack**: Used by `PSH` and `POP`

## Addressing

* Immediate values are prefixed with `#`
* Register values can optionally be pre prefixed with `$`
* Register operands are referenced by index

Jump targets are absolute and computed as: Address = 256 × arg1 + arg2

## Control Flow Instructions

### `JMP #arg1 #arg2`

Unconditional jump.

```
PC → 256 × arg1 + arg2
```

### `CND #arg1 #arg2`
Conditional jump.

```
if CF == true:
    PC → 256 × arg1 + arg2
```

### `PSH #arg1 #arg2`
Pushes the current program counter onto the stack and jumps to a specified instruction.

```
PC → 256 × arg1 + arg2
```

### `POP`
Pops a program counter value from the stack and jumps to it.

### `NOP`
No operation.

## Data Movement Instructions

### `LDA $arg1`
Load a register value into the accumulator.

```
A → R[reg]
```

### `LDI #arg1`
Load an immediate value into the accumulator.

```
A → imm
```

### `STA $arg1`
Store the accumulator into a register.

```
R[reg] → A
```

### `STI #arg1`
Store the immediate value to register 0.

```
R[0] → imm
```

## Arithmetic Instructions

All arithmetic wraps modulo 256.

### `ADD $arg1`
Add a register to the accumulator.

```
A → A + R[reg]
```

### `SUB $arg1`
Subtract a register from the accumulator.

```
A → A - R[reg]
```

## Bitwise Instructions

### `AND $arg1`
Bitwise AND between the accumulator and a register.

```
A → A & R[reg]
```

### `OR $arg1`
Bitwise OR between the accumulator and a register.

```
A → A | R[reg]
```

### `XOR $arg1`
Bitwise XOR between the accumulator and a register.

```
A → A ^ R[reg]
```

## Shift Instructions

### `LSH $arg1`
Logical left shift of the accumulator.

```
A → (A << R[reg]) mod 256
```

*Note: High bits are discarded.*


### `RSH $arg1`
Logical right shift of the accumulator.

```
A → A >> R[reg]
```

*Note: Zero-fill; high bits are shifted in as `0`.*

## Comparison Instruction

### `CMP mode #arg1`
Compares a register value against the accumulator and sets the comparison flag (`CF`).

Mode: Condition tested

 0 : `False`
 
 1 :`R[reg] > A`
 
 2 : `R[reg] == A`
 
 3 : `R[reg] >= A`
 
 4 : `True`
 
 5 : `R[reg] <= A`
 
 6 : `R[reg] != A`
 
 7 : `R[reg] < A`

*Note: All comparisons are **unsigned**.*
