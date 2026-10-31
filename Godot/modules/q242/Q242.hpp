#ifndef Q242_H
#define Q242_H

#include "core/object/ref_counted.h"

class Q242 : public RefCounted {
	GDCLASS(Q242, RefCounted);

protected:
	static void _bind_methods(); // Exposes methods and properties to GDScript

public:
	Q242();

	void read_bin(String filename);

	void run(uint64_t cycles);
};

#endif