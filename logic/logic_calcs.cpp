#include <iostream>
#include <vector>
#include <sstream>

int main() {
    std::vector<int> numbers;
    int num;

    while (std::cin >> num) {
        numbers.push_back(num);
    }

    for (int n : numbers) {
        std::cout << n * 2 << std::endl;
    }

    return 0;
}
