//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Sergey Mironchuk on 26.08.15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    private var opStack = Array<Op>()
    
    private var knownOps = Dictionary<String, Op>()
    
    init() {
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0 }
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
    }
    
    func pushOperand (operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOpts: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOpts)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOpts)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOpts)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        if let stack = displayStack() {
            println("formula: \(stack)")
        }
        if (result != nil) {
            println("stack: \(opStack) = \(result!) with \(remainder) left over")
        } else {
            println("stack: \(opStack) = \(result) with \(remainder) left over")
        }
        return result
    }
    
    private func displayStack(ops: [Op]) -> (result: String?, remainingOpts: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .UnaryOperation(let operationSymbol, _):
                let displayResult = displayStack(remainingOps)
                if let operand = displayResult.result {
                    return ("\(operationSymbol)(\(operand))", displayResult.remainingOpts)
                }
            case .BinaryOperation(let operationSymbol, _):
                let displayResult1 = displayStack(remainingOps)
                if let operand1 = displayResult1.result {
                    let displayResult2 = displayStack(displayResult1.remainingOpts)
                    if let operand2 = displayResult2.result {
                        return ("(\(operand1)\(operationSymbol)\(operand2))", displayResult2.remainingOpts)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func displayStack() -> String? {
        let (result, remainder) = displayStack(opStack)
        return result
    }
}
