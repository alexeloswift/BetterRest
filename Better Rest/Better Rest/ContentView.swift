//
//  ContentView.swift
//  Better Rest
//
//  Created by Alex Diaz on 11/20/21.
//
import CoreML
import SwiftUI

struct ContentView: View {
    
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var sleepTime = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    let idealBedtime = calculateBedtime
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time.", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    }
                Section {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: (0.25))
                    }
                Section {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Picker("Cups of Coffee", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text("\($0)")
                        }
                    }
                }
                
                    Section(header: Text("Recommended Bedtime")) {
                        HStack(spacing: 10) {
                            Text(sleepTime)
                        }
                    }
            
                
           
                }
            
            .navigationTitle("Better Rest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            
            
        }
    }
    
    func calculateBedtime () {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let _sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            sleepTime = formatter.string(from: _sleepTime)
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was an issue calculating your bedtime."
        }
            showingAlert = true
            
    }
    
   
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
