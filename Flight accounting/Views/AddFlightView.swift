//
//  AddFlightView.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 24.11.2024.
//

import SwiftUI

struct AddFlightView: View {
    @State private var flightNumber: String = ""
    @State private var departureFrom: String = ""
    @State private var departureAirportCode: String = "" // Новый код
    @State private var arrival: String = ""
    @State private var arrivalAirportCode: String = "" // Новый код
    @State private var selectedAircraft: Aircraft? = nil
    @State private var availableSeats: Int = 0

    @State private var departureDateTime: Date = Date() // Объединённая дата и время вылета
    @State private var arrivalDateTime: Date = Date() // Объединённая дата и время прибытия
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String? = nil
    

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var flightModel: FlightModel
    @ObservedObject var aircraftModel: AircraftModel
    
    @State private var saveResult: String? = nil

    var body: some View {
        VStack {
            Text("Добавление рейса").font(.title2).foregroundStyle(Color.gray)
                .padding(.bottom, 20)

            Form {
                Section(header: Text("Основные данные рейса").font(.subheadline).foregroundStyle(Color.gray)) {
                    TextField("Номер рейса", text: $flightNumber)
                    TextField("Пункт вылета", text: $departureFrom)
                    TextField("Код аэропорта вылета", text: $departureAirportCode) // Новый ввод

                    DatePicker("Дата и время вылета", selection: $departureDateTime, displayedComponents: [.date, .hourAndMinute])

                    TextField("Пункт прибытия", text: $arrival)
                    TextField("Код аэропорта прибытия", text: $arrivalAirportCode) // Новый ввод

                    DatePicker("Дата и время прибытия", selection: $arrivalDateTime, displayedComponents: [.date, .hourAndMinute])
                }
                Section(header: Text("Самолет").font(.subheadline).foregroundStyle(Color.gray)) {
                    Picker("Выберите модель самолета", selection: $selectedAircraft) {
                        ForEach(aircraftModel.allAircrafts) { aircraft in
                            Text("\(aircraft.model) (мест: \(aircraft.capacity))")
                                .tag(aircraft as Aircraft?)
                        }
                    }
                }
                if let aircraft = selectedAircraft {
                    Text("Мест на борту: \(aircraft.capacity)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                Button("Закрыть") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)

                Spacer()

                Button("Сохранить рейс", action: saveFlight)
                    .disabled(
                        flightNumber.isEmpty ||
                        departureFrom.isEmpty ||
                        departureAirportCode.isEmpty ||
                        arrival.isEmpty ||
                        arrivalAirportCode.isEmpty ||
                        selectedAircraft == nil
                    )
                    .buttonStyle(.borderedProminent)
            }
            .padding(.top, 20)
        }
        .onAppear {
            aircraftModel.loadAircrafts()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertMessage ?? ""),
                dismissButton: .default(Text("ОК"))
            )
        }
    }

    private func saveFlight() {
        guard let aircraft = selectedAircraft else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let newFlight = Flight(
            flightNumber: flightNumber,
            airportId: departureAirportCode,
            departureFrom: departureFrom,
            departureDate: formatter.string(from: departureDateTime),
            departureTime: DateFormatter.localizedString(from: departureDateTime, dateStyle: .none, timeStyle: .short),
            airportArrivalId: arrivalAirportCode,
            arrival: arrival,
            arrivalDate: formatter.string(from: arrivalDateTime),
            arrivalTime: DateFormatter.localizedString(from: arrivalDateTime, dateStyle: .none, timeStyle: .short),
            availableSeats: aircraft.capacity
        )
        
        FlightsManager().addFlight(newFlight)

        
        alertMessage = "Рейс \(flightNumber) успешно добавлен"
        flightModel.loadFlights()
        flightModel.loadArrivals(to: "SVO")
        flightModel.loadDepartures(from: "SVO")
        showAlert = true
        resetForm()
    }
    
    private func resetForm() {
        flightNumber = ""
        departureFrom = ""
        departureAirportCode = ""
        arrival = ""
        arrivalAirportCode = ""
        selectedAircraft = nil
        availableSeats = 0
    }
}



#Preview {
    let testAircraftModel = AircraftModel()
    let testFlightModel = FlightModel()
    
    return AddFlightView(
        flightModel: testFlightModel,
        aircraftModel: testAircraftModel
    )
}
