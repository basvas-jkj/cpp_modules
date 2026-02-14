#pragma once
#include <string>
#include "cr.hpp"

template <class F>
void execute(F&& lambda, cr<std::string> a)
{
	lambda(a);
}