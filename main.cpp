#include <iostream>
 
using namespace std;
 
double add(double num1, double num2) {
    return num1 + num2;
}
 
double subtract(double num1, double num2) {
    return num1 - num2;
}
 
double multiply(double num1, double num2) {
    return num1 * num2;
}
 
double divide(double num1, double num2) {
    if (num2 != 0) {
        return num1 / num2;
    } else {
        cout << "错误：除数不能为零！" << endl;
        return 0;
    }
}
 
int main() {
    double num1, num2;
    char op;
 
    cout << "请输入第一个数字：";
    cin >> num1;
 
    cout << "请输入运算符（+、-、*、/）：";
    cin >> op;
 
    cout << "请输入第二个数字：";
    cin >> num2;
 
    double result;
 
    switch (op) {
        case '+':
            result = add(num1, num2);
            break;
        case '-':
            result = subtract(num1, num2);
            break;
        case '*':
            result = multiply(num1, num2);
            break;
        case '/':
            result = divide(num1, num2);
            break;
        default:
            cout << "错误：无效的运算符！" << endl;
            return 0;
    }
 
    cout << "结果：" << result << endl;
 
    return 0;
}