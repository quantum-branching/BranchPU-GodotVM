#include "register_types.hpp"

#include "core/object/class_db.h"
#include "Q242.hpp"

void initialize_q242_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}

	ClassDB::register_class<Q242>();
}

void uninitialize_q242_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
}