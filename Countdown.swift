//
//  Created by Cuma Aktaş on 28.08.2025.
//

import SwiftUI

struct Countdown: View {
    @State private var maxValue: Double = 10
    @State private var sliderValue: Double = 10
    
    @State private var timer: Timer?
    @State private var isRunning = false
    @State private var infoText: String = "Set a Timer in Seconds"
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("10") {
                    setMaxValue(10)
                }
                .buttonStyle(.borderedProminent)
                
                Button("50") {
                    setMaxValue(50)
                }
                .buttonStyle(.borderedProminent)
                
                Button("100") {
                    setMaxValue(100)
                }
                .buttonStyle(.borderedProminent)
            }

            Slider(
                value: $sliderValue,
                in: 0...maxValue,
                step: 1
            )
            .padding()
            if isRunning {
                Text("\(Int(sliderValue)) / \(Int(maxValue)) seconds")
            } else if !isRunning && sliderValue > 0 {
                Text("\(Int(sliderValue)) seconds")
            } else {
                Text(infoText)
            }

            HStack {
                Button {
                    maxValue = sliderValue
                    startTimer()
                } label: {
                    Image(systemName: "play.fill")
                }
                .disabled(isRunning || sliderValue <= 0)
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
                Button {
                    pauseTimer()
                } label: {
                    Image(systemName: "pause.fill")
                }
                .disabled(!isRunning)
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
                Button {
                    resetTimer()
                } label: {
                    Image(systemName: "gobackward")
                }
                .disabled(!isRunning && sliderValue == maxValue)
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
            }
            .font(.title)
            .bold()
            .foregroundStyle(Color.white)
            
        }
        .padding()
    }
    
    private func setMaxValue(_ newValue: Double) {
        maxValue = newValue
        sliderValue = newValue
        pauseTimer()
    }
    
    private func startTimer() {
        guard !isRunning, sliderValue > 0 else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if sliderValue > 0 {
                sliderValue -= 1
            } else {
                pauseTimer()
                timerFinished()
            }
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        pauseTimer()
        sliderValue = maxValue
    }
    
    private func timerFinished() {
        maxValue = 10
        infoText = "Time's Up!"
        
    }
}

#Preview {
    Countdown()
}
