import <r>;
import <string>;
import "unit.hpp";

using namespace std;

int main()
{
	auto lambda = [](cr<string> message)
	{
		println("{}", message);
	};

	execute(lambda, "C++ header units via CMake!");

	return 0;
}