//
//  ComputationManager.swift
//  cw_1
//
//  Created by Кирилл Титов on 21.11.2024.
//

import Foundation

class ComputationManager {
    
    weak var viewController: ViewController?
    var task: Task<Void, Never>?
    
    init(viewController: ViewController) {
        self.viewController = viewController
    }
    
    func startComputation() {
        task = Task {
            await performLongComputations()
        }
    }
    
    func cancelComputation() {
        task?.cancel()
        viewController?.updateStatus(message: "Вычисления отменены")
    }
    
    private func performLongComputations() async {
        let maxValue = 20
        var progress: Float = 0.0
        var lastFactorial: Int = 0
        
        // Вычисление факториала для чисел от 1 до 20
        for i in 1...maxValue {
            if Task.isCancelled { return }
            
            // Симуляция долгих вычислений
            await Task.sleep(500_000_000)
            
            // Вычисление факториала
            let factorial = await calculateFactorial(of: i)
            lastFactorial = factorial // Сохраняем последний факториал
            
            // Обновление прогресса
            progress = Float(i) / Float(maxValue)
            viewController?.updateProgress(progress: progress)
            
            // Обновление UI с текущим факториалом (не выводим все, только для последнего числа)
            viewController?.updateStatus(message: "Факториал для числа \(i) = \(factorial)")
        }
        
        // После вычисления всех факториалов, выводим только последний результат (для числа 20)
        viewController?.updateStatus(message: "Вычисления завершены.\n\nФакториал 20 = \(lastFactorial)")
    }
    
    private func calculateFactorial(of number: Int) async -> Int {
        var result = 1
        for i in 1...number {
            result *= i
            await Task.sleep(100_000_000) // Задержка для симуляции вычислений
        }
        return result
    }
}
