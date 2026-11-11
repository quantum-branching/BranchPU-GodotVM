cd godot-4.6
scons platform=linuxbsd target=template_release profile='../BPU-VM/Godot/custom.py'
cd ..
"$GODOT" BPU-VM/project.godot --export-release "Linux" ../Linux_x86_64_BPU_VM.x86_64