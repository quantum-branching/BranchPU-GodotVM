#include "Q242.hpp"
#include "Encoding242.hpp"

#include "core/object/class_db.h" // Required for ClassDB binding macros

#define u8 unsigned char
#define u16 unsigned short

#define push(stack, ptr, src) (stack)[(ptr)++] = src
#define pop(stack, ptr, dest) dest = (stack)[--(ptr)]

/// Program Counter
u16 PC__242 = 0;
/// Carry Flag
u8 CF__242 = 0;
/// Zero Flag
u8 ZF__242 = 0;

u8 call_stack_ptr__242 = 0;

u8 binary__242[BINARY_SIZE__242];
u8 RAM__242[RAM_SIZE__242];
u8 cache__242[16];
u16 call_stack__242[CALL_STACK_SIZE__242];
u8 registers__242[REG_COUNT__242 + 1];

void readBin242(const char *filename) {
	FILE *file = fopen(filename, "rb");
	if (file) {
		fread(binary__242, 1, BINARY_SIZE__242, file);
		fclose(file);
	} else {
		printf("Error: Could not open file %s\n", filename);
	}
}
// ----------------------------------------------------------------------------

Q242::Q242() {
	
}

void Q242::read_bin(String filename) {
	CharString ascii_filename = filename.utf8();
	readBin242(ascii_filename.get_data());
}

#define regs registers__242
#define binary binary__242

#define byte0 binary[PC]
#define byte1 binary[PC + 1]

#define setReg(destNibble, value) regs[(destNibble) ? (destNibble) : REG_COUNT__242] = value

void Q242::run(uint64_t cycles) {
	u16 PC = PC__242;

	u8 nibble0;
	u8 nibble1;
	u8 nibble2;
	u8 nibble3;

	for(uint64_t i = 0; i < cycles; i++) {
		nibble0 = byte0 & 0xF0;
		nibble1 = byte0 & 0x0F;
		nibble2 = byte1 & 0xF0;
		nibble3 = byte1 & 0x0F;

		nibble0 >>= 4;
		nibble2 >>= 4;

		switch(nibble0) {
			case ADD__242:
				setReg(nibble1, regs[nibble2] + regs[nibble3]);
				break;
			case SUB__242:
				setReg(nibble1, regs[nibble2] - regs[nibble3]);
				break;
			case ADI__242:
				setReg(nibble1, regs[nibble1] + byte1);
				break;
			case LDI__242:
				setReg(nibble1, byte1);
				break;
			case BIT__242: {
				u8 XOR = regs[nibble1] ^ regs[nibble3];
				u8 IOR = regs[nibble1] | regs[nibble3];
				u8 NOR = ~IOR;

				u8 ior_flag = 0 - ((nibble2 >> 1) & 0x1);
				u8 nor_flag = 0 - ((nibble2 >> 2) & 0x1);
				u8 inv_flag = 0 - (nibble2 & 0x1);

				setReg(nibble1, (XOR | (IOR & ior_flag) | (NOR & nor_flag)) ^ inv_flag);
				break; }
			case BRH__242:
				PC = ((((ZF__242 << 1) | CF__242) != (nibble2 & 0x3)) == !(nibble2 & 0x4)) ? (regs[nibble1] - 1) << 1 : PC;
    			break;
			case CAL__242:
				if((((ZF__242 << 1) | CF__242) != (nibble2 & 0x3)) == !(nibble2 & 0x4)) {
					push(call_stack__242, call_stack_ptr__242, PC);
					PC = (regs[nibble1] - 1) << 1;
				}

				break;
			case RET__242:
				pop(call_stack__242, call_stack_ptr__242, PC);
				PC -= 2;
				break;
			case ACH__242:
				for(u8 i = 0; i < 16; i++) {
					cache__242[i] = RAM__242[i + (regs[nibble1] & 0xF0)];
				}

				break;
			case SCH__242:
				for(u8 i = 0; i < 16; i++) {
					RAM__242[i + (regs[nibble1] & 0xF0)] = cache__242[i];
				}

				break;
			case RCH__242:
				setReg(nibble1, cache__242[nibble2]);
				break;
			case WCH__242:
				cache__242[nibble1] = nibble2;
				break;
			default:
				break;
		}

		PC += 2;
	}

	PC__242 = PC;
}

#undef setReg

#undef binary
#undef regs

void Q242::_bind_methods() {
	ClassDB::bind_method(D_METHOD("read_bin", "filename"), &Q242::read_bin);
	ClassDB::bind_method(D_METHOD("run", "cycles"), &Q242::run);
}