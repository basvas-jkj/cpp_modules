module;
#include <print>
#include <string>
module cwl;

using namespace std;

void write_line(cr<string> message)
{
	println("{}", message);
}