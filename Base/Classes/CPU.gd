@warning_ignore_start("integer_division")
class_name CPU extends RefCounted

const INSTRUCTION_LIMIT:int = 4095
const INSTRUCTION_STEP:int = 2
const INSTRUCTION_OFFSET:int = 8
const DATA_OFFSET:int = 1
const BYTE_MASK:int = 255

var binary:PackedByteArray

var regs:PackedByteArray
var pcStack:PackedInt32Array
var valStack:PackedByteArray
var accum:int
var cond:int

var ports:Array[Port]

var instruction:int
var lastInstruction:int
var opcode:int
var mod:int
var data:int
var regData:int

@warning_ignore("shadowed_variable")
func _init(binary:PackedByteArray) -> void:
	self.binary = binary
	instruction = 0
	accum = 0
	cond = 0
	regs.resize(256)
	regs.fill(0)
	pcStack = []
	valStack = []
	binary.resize(4096)
	lastInstruction = locateNOP()
	
func locateNOP() -> int:
	var line:int = 0
	while line < INSTRUCTION_LIMIT / INSTRUCTION_STEP:
		if !binary[line * INSTRUCTION_STEP] && binary[line * INSTRUCTION_STEP + DATA_OFFSET] == line:
			return 2 * line
		line += 1
	return INSTRUCTION_LIMIT - 1

@warning_ignore("shadowed_variable")
func bind(ports:Array[Port]) -> void:
	self.ports = ports
	for i:Port in ports:
		if i:
			i.reset()

##Excutes <cycles> binary instructions
func exec(cycles:int):
	const OPCODE_MASK:int = 3
	const MOD_MASK:int = 7
	const IMMEDIATE_FLAG:int = 1
	const INVERT:int = 1
	const CND_LT:int = 1
	const CND_EQ:int = 2
	const CND_NOT:int = 2
	const STK_POP:int = 2
	
	if instruction == lastInstruction:
		OS.low_processor_usage_mode = true
		return
	
	for i in cycles:
		opcode = binary[instruction] >> OPCODE_MASK
		mod = binary[instruction] & MOD_MASK
		data = binary[instruction + DATA_OFFSET]
		
		if (!(mod & IMMEDIATE_FLAG) || opcode == 13 || opcode == 19) && opcode != 14:
			regData = regs[data]
		else:
			regData = data
		#print("op:", opcode, " mod:", mod, " data:", data, " (", regData, ") @", instruction)
		match opcode:
			0:
				instruction = INSTRUCTION_STEP * ((data - 1 + (mod << INSTRUCTION_OFFSET)) & INSTRUCTION_LIMIT)
			1:
				accum = (accum + regData) & BYTE_MASK
			2:
				accum = (accum - regData) & BYTE_MASK
			3:
				accum = (accum << regData) & BYTE_MASK
			4:
				accum = (accum >> regData) & BYTE_MASK
			5:
				accum = (accum & regData) & BYTE_MASK
			6:
				accum = (accum | regData) & BYTE_MASK
			7:
				accum = (accum ^ regData) & BYTE_MASK
			8:
				accum = regData
			9:
				regs[data & BYTE_MASK] = accum
			10:
				instruction = cond * INSTRUCTION_STEP * ((data - 1 + (mod << INSTRUCTION_OFFSET)) & INSTRUCTION_LIMIT) + (INVERT ^ cond) * instruction
			11:
				pcStack.append(instruction)
				instruction = INSTRUCTION_STEP * ((data - 1 + (mod << INSTRUCTION_OFFSET)) & INSTRUCTION_LIMIT)
			12:
				instruction = pcStack.get(pcStack.size() - 1)
				pcStack.remove_at(pcStack.size() - 1)
			13:
				cond = int(((accum < regData) && (mod & CND_LT != 0)) || ((accum == regData) && (mod & CND_EQ))) ^ (mod >> CND_NOT)
			14:
				cond = int(((accum < data) && (mod & CND_LT != 0)) || ((accum == data) && (mod & CND_EQ))) ^ (mod >> CND_NOT)
			15:
				if mod & STK_POP:
					if (mod & IMMEDIATE_FLAG):
						accum = valStack.get(valStack.size() - 1)
					else:
						regs[data] = valStack.get(valStack.size() - 1)
					if valStack.size(): valStack.remove_at(valStack.size() - 1)
				else:
					valStack.append(regData)
			16:
				accum = ports[mod].output & BYTE_MASK
			17:
				regs[data] = ports[mod].output & BYTE_MASK
			18:
				ports[mod].input = accum
				ports[mod].p26(accum)
			19:
				ports[mod].input = regData
				ports[mod].p26(regData)
			20:
				valStack.get(valStack.size() - (regData + 1))
		
		instruction = (instruction + INSTRUCTION_STEP) & INSTRUCTION_LIMIT
