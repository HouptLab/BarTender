#include "BarObjects.hpp"RatType::RatType(unsigned long num) {	id = num;	if (num % 2 == 0) group = 1;	else group = 0;	start_time = SecsNow();	end_time = 0;	}