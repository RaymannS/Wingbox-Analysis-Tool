#include <iostream>
#include <vector>
#include <iomanip>

int main() {
    std::vector<double> numbers;
    double num;

    while (std::cin >> num) {
        numbers.push_back(num);
    }

    for (double n : numbers) {
        std::cout << std::setprecision(15) << n * 2 << std::endl;
    }

    return 0;
}
