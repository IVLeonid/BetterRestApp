import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                    
                    
                }
                
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                .font(.headline)
                
                Section("Daily coffee intake") {
                    Picker("Number of cups", selection: $coffeeAmount) {
                        ForEach(1...15, id: \.self) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }
                }
                .font(.headline)
                
                Spacer()
                    .frame(minHeight: 40)
                    .listRowBackground(Color.clear)
                
                showResult
            }
            .navigationTitle("BetterRest")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var result: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            return "\(sleepTime.formatted(date: .omitted, time: .shortened))"
            
        } catch {
            return "Error"
        }
    }
    
    var showResult: some View {
        Section("Your ideal bedtime is") {
            Text(result)
        }
        .listRowBackground(Color.clear)
        .frame(maxWidth: .infinity, alignment: .center)
        .font(Font.system(size: 30, weight: .heavy))
        .foregroundColor(.primary)
    }
}


#Preview {
    ContentView()
}
