# **Syntax**

A statement may be terminated by either a newline or a semicolon. Whitespace is otherwise ignored and therefore blocks are delimited using `{}`. Placing `#ignore '\n'` at the beginning of a file causes newlines to be treated as ordinary whitespace, requiring every statement to end with a semicolon. Comments are started with `//` and preprocessor commands start with `#`.

# **Data Types**

## **Integers**

Integers are 8 bits long and unsigned, storing any value from 0 to 255\. All arithmetic performed on integers performed modulo 256\. It is convention to maintain this modulo behavior with custom functions or to annotate how values outside of this range are handled in the new function. Due to this convention, 255 can be used to represent \-1.  
```rust
int over = 276 // over = 20
int under = -6 // under = 250
int hex = 0x78 // hex = 120
```

## **Characters**

Characters are also 8 bits and use the extended ASCII encoding (Windows-1252). Characters are wrapped in single quotes `‘` and a compiler error will be thrown if a character has a length not equal to 1\.  
```rust
char a = ‘ ’ // Stored as 0x20
char b = ‘bad’ // Error: Character with length != 1
char c = 81 // Stores ‘Q’ as 0x51
```

## **Booleans**

Booleans take up 8 bits but store 1 bit of information: true or false. When casting to a boolean, any value greater than 0 is considered to be true and any other value is considered to be false.

## **Arrays**

An array is an object that is a contiguous block of numbers in the stack (or in RAM when using the `mem` keyword). See State Activity to see default modification and Ownership to see modification using mem keyword.

```rust
arr a = [1, 2, 3, 4]
arr b = [a.0, a.2, a.3]
```

## **Strings**

A string is an array of character values. See array for more information. Strings rely on size data rather than null terminators unlike C. However, using a null terminator for portability **is not** discouraged. Strings are wrapped in double quotes `“` and no content in the strings can be used for code parsing.  
```rust
str greetings = “Hello, World” // Typical string declaration
str cstr = “Hello, World\0” // C string declaration
```

## **Void**

Void is not a real data type and hence a variable can not have the void type. Instead, void represents that no information has been passed around. A void function doesn’t return any information and setting a variable to the result of a void function will result in a compile-time error.

# **Variables**

Primitive variables contain data as 8 bit registers and the type determines how that data is handled. Objects are stored on the stack and referenced via a stack pointer unless the object is declared using the `mem` keyword. Setting a primitive variable to the value of a primitive data type will result in a cast between those two types. Setting an array variable to a string or vice versa will also result in a cast. In both cases the internal data stays the same unless the cast is to a boolean in which case the data is set to a 1 or a 0\.

# **Scope**

All non-global variables are temporary. Global variables are variables that are defined outside of any curly bracket. Every left curly bracket opens a new scope and every right curly bracket closes a scope. A variable resides in the smallest scope that contains its declaration. Once that scope finishes, the variable is no longer accessible.

# **Ownership**

Object variables are the sole owners of objects. Objects are created by declaring an object variable and are freed once the creator variable becomes out of scope. The ownership of the object can be transferred if a function returns an object that it created, if the object uses the `mem` keyword. When an object is set to a function that returns an object, the original object is freed and replaced by the return value of the function.

# **State Activity**

State activity governs which object fields can be modified. These rules do not facilitate fields for objects that use the `mem` keyword. Creating an object field makes other objects fields inactive. When an object leaves a scope, the last active object field becomes active. The active object field becomes temporarily inactive when a function is called until that function resolves.

# **Functions**

# **Operators**

# **Conversions**

# **Control Flow**
