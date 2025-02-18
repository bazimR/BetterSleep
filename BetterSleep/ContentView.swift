//
//  ContentView.swift
//  BetterSleep
//
//  Created by Rishal Bazim on 18/02/25.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeUp
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    static var defaultWakeUp: Date {
        var components = DateComponents()
        components.hour = 8
        components.minute = 30
        return Calendar.current.date(from: components) ?? Date.now
    }
    var body: some View {
        NavigationStack {
            ZStack {
                RadialGradient(
                    stops: [

                        .init(color: .gray, location: 0.5),
                        .init(color: .white, location: 0.5),
                    ],
                    center: .init(x: 0.1, y: 1),
                    startRadius: 400,
                    endRadius: 500
                ).ignoresSafeArea()
                VStack{
                    Form {
                        Section {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("When do you want to wake up ?").font(
                                    .headline)
                                DatePicker(
                                    "Please enter wake up time", selection: $wakeUp,
                                    displayedComponents: .hourAndMinute
                                ).labelsHidden()
                            }
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Desired amount of sleep").font(.headline)
                                Stepper(
                                    "\(sleepAmount.formatted()) hours",
                                    value: $sleepAmount,
                                    in: 6...12,
                                    step: 0.25
                                )
                            }
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Daily coffee intake").font(.headline)
                                Picker(
                                    "Coffe cups",
                                    selection: $coffeeAmount
                                ) {
                                    ForEach(1..<25) {
                                        Text("\($0)").tag($0)
                                    }
                                }
                            }
                        }
                        Button("Calculate", action: calculateBedTime)
                            .font(.title3)

                        if !alertMessage.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(alertTitle)
                                    .foregroundColor(.primary)
                                    .font(.headline)
                                Text(
                                    alertMessage
                                ).font(.largeTitle)
                            }
                        }
                    }.scrollContentBackground(.hidden).background(
                        Color.clear
                    )

                }
            }.navigationTitle("Better Sleep")
        }
    }

    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents(
                [.hour, .minute],
                from: wakeUp
            )
            let hours = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0) * 60

            let prediction = try model.prediction(
                wake: Double(hours + minutes),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )

            let bedTime = wakeUp - prediction.actualSleep

            alertTitle = "Your ideal bed time is"
            alertMessage =
                "\(bedTime.formatted(date: .omitted, time: .shortened))"
        } catch {
            alertTitle = "Error something went wrong"
            alertMessage = "Counldnt calculate you bedtime, Please try again."
        }
    }
}

#Preview {
    ContentView()
}
