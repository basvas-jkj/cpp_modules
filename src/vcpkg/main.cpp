import std;
import <nlohmann/json.hpp>;

using namespace std;
using namespace nlohmann;

int main()
{
	json root;
	root["a"] = 1;
	root["b"].push_back(2);
	root["b"].push_back(3);
	root["c"]["d"] = 4;
	root["c"]["e"] = 5;

	println("Vcpkg via CMake: {}!", root.dump());
}