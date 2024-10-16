//
//  ContentView.swift
//  BetterRest
//
//  Created by Mag isb-10 on 08/10/2024.
//

import CoreML
import SwiftUI

struct ContentView: View {
  
  @State private var wakeUp = defaultWakeTime
  @State private var sleepAmount = 8.0
  @State private var coffeeAmount = 1
  @State private var recommendedBedtime = ""
  
  static  var defaultWakeTime: Date {
    var components = DateComponents()
    components.hour = 7
    components.minute = 0
    return Calendar.current.date(from: components) ?? .now
  }
  
  
  var body: some View {
    NavigationStack {
      Form {
        Section("When do you wanna wake up?") {
          DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
            .labelsHidden()
            .onChange(of: wakeUp) {
              calculateBedtime()
            }
        }
        
        Section("Desired amount of sleep?") {
          Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
            .onChange(of: sleepAmount) {
              calculateBedtime()
            }
        }
        
        Section("Daily coffee intake") {
          Picker("^[\(coffeeAmount) cup](inflect: true)", selection: $coffeeAmount) {
            ForEach(1..<21, id: \.self) { value in
              Text("\(value)")
            }
          }
          .onChange(of: coffeeAmount) {
            calculateBedtime()
          }
          
        }
        
        Section("Your ideal bedtime is") {
          Text(recommendedBedtime)
            .font(.largeTitle)
            .fontWeight(.bold)
        }
      }
      .navigationTitle("BetterRest")
    }
  }
  
  
  func calculateBedtime() {
    do {
      let config = MLModelConfiguration()
      let model = try SleepCalculator(configuration: config)
      
      let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
      let hours = (components.hour ?? 0) * 60 * 60
      let minutes = (components.second ?? 0) * 60
      
      let prediction = try model.prediction(wake: Double(hours + minutes), estimatedSleep: sleepAmount, coffee: Double (coffeeAmount))
      
      let sleepTime = wakeUp - prediction.actualSleep
      recommendedBedtime = sleepTime.formatted(date: .omitted, time: .shortened)
    } catch {
      recommendedBedtime = "Sorry, there was a problem calculating your bedtime."
    }
  }
  
}

#Preview {
  ContentView()
}
