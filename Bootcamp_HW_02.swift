import Foundation

func calculator(_ a: Double, _ b: Double, operation: String) -> Double? {
    switch operation {
    case "+": return a + b
    case "-": return a - b
    case "*": return a * b
    case "/": return b != 0 ? a / b : nil
    default: return nil
    }
}

func getNumber(prompt: String) -> Double? {
    for attempt in 1...3 {
        print(prompt)
        if let input = readLine(), let number = Double(input) {
            return number
        } else {
            print("Invalid number. Attempt \(attempt)/3.")
        }
    }
    print("Too many invalid attempts. Exiting...")
    return nil
}

func getOperation(prompt: String) -> String? {
    let validOps = ["+", "-", "*", "/"]
    for attempt in 1...3 {
        print(prompt)
        if let input = readLine(), validOps.contains(input) {
            return input
        } else {
            print("Invalid operation. Attempt \(attempt)/3.")
        }
    }
    print("Too many invalid attempts. Exiting...")
    return nil
}

guard let a = getNumber(prompt: "Enter first number:") else { exit(1) }
guard let b = getNumber(prompt: "Enter second number:") else { exit(1) }
guard let op = getOperation(prompt: "Choose operation (+, -, *, /):") else { exit(1) }

if op == "/" && b == 0 {
    print("Error: Division by zero is not allowed. Exiting...")
    exit(1)
}

if let result = calculator(a, b, operation: op) {
    print("Result: \(result)")
} else {
    print("Invalid operation.")
}
