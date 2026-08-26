### Obtaining Executable

Download pre-compiled Executable (Windows or Linux)
* [Navigate to Releases](https://github.com/quantum-branching/BranchPU-VM/releases)
* Download appropriate Executable (labeled \<OS\>\_Godot\_\<Architecture\>\_BPU\_VM)

Compile from Source (Any platform)
* Download Source
    * From Release
    * From Branch
* Download [Godot/Export Templates](https://godotengine.org/download/archive/4.6.1-stable/) (if you don't already have it)
* Open Godot
* Import Source
* Setup Export Templates (if you haven't already)
    * Editor > Manage Export Templates
    * Install from file
* Project > Export > Export Project

### Opening Files
You can open a BPU file in the BPU Editor by passing that file as an argument
* Drop file on executable
* Open file with BranchPU-VM
* Command-line `[BranchPU-VM filepath] [BPU file]`

### Editor
You start in the BPU Editor

The Editor:
* Highlights text and suggests operations
* Supports assembly
* Supports preproccessor functions
  * `#removeBlank;`
  * `#import x`
      * Includes a BPU package
  * `#define x y`
      * Defines all occurences of `x` to be `y`

### Assembler
You can click the Quantum Branching icon to enter the assembler

The Assembler:
* Assembles unprocessed BPU assembly into processed BPU assembly
* Executes processed assembly
* Displays memory information
* Can display processed assembly when pressing `alt`
