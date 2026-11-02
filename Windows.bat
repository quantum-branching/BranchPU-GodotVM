cd godot-4.6
scons platform=windows target=template_release profile='../BPU-VM/Godot/custom.py' d3d12=no
cd ..
"$GODOT" BPU-VM/project.godot --export-release "Windows" ../Windows_x86_64_BPU_VM.x86_64