#pragma once

template <class T>
using cr = const T&;

template <class F, class T>
void execute(F&& lambda, cr<T> a)
{
	lambda(a);
}