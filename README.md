### Obtaining Executable

Download pre-compiled Executable (Windows, Linux or BSD)
* [Navigate to Releases](https://github.com/quantum-branching/BranchPU-VM/releases)
* Download appropriate Executable (labeled \<OS\>\_\<Architecture\>\_BPU\_VM)

Compile from Source (Any platform)
* Download Source
    * From Release
    * From Branch
* Download the [Godot Source](https://github.com/godotengine/godot/tree/4.6)
* Rename BranchPU-VM Source Directory to BPU-VM
* Move Godot Source to be in the same directory as BranchPU-VM Source
* Run the appropriate script file \(This compile a minimal version of Godot with custom modules\)
 * Linux.sh to compile for Linux or BSD on Linux or BSD
 * Windows.sh to compile for Windows on Linux or BSD
 * Linux.bat to compile for Linux or BSD on Windows
 * Windows.bat to compile for Windows on Windows

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
