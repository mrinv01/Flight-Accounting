//
//  AddPassengerview.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 23.11.2024.
//

import SwiftUI

struct RegisterPassengerView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth: Date = Date() // Используем Date вместо String
    @State private var passportNumber: String = ""
    @State private var contactPhone: String = ""
    @State private var selectedFlight: Flight? = nil
    @State private var selectedDate: String = ""
    @State private var registrationResult: String? = nil

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var flightModel: FlightModel

    var body: some View {
        VStack {
            Text("Регистрация пассажира")
                .font(.title2)
                .foregroundStyle(Color.gray)
                .padding(.bottom, 20)

            Form {
                Section(header: Text("Личные данные").font(.subheadline).foregroundStyle(Color.gray)) {
                    TextField("Имя", text: $firstName)
                        

                    TextField("Фамилия", text: $lastName)
                        

                    DatePicker("Дата рождения", selection: $dateOfBirth, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }

                Section(header: Text("Контактные данные").font(.subheadline).foregroundStyle(Color.gray)) {
                    TextField("Номер паспорта", text: $passportNumber)
                    TextField("Телефон", text: $contactPhone)
                }

                Section(header: Text("Выбор рейса").font(.subheadline).foregroundStyle(Color.gray)) {
                    Picker("Выберите рейс", selection: $selectedFlight) {
                        ForEach(flightModel.allFlights) { flight in
                            Text("\(flight.flightNumber) - \(flight.departureFrom) → \(flight.arrival)")
                                .tag(flight as Flight?)
                        }
                    }
                    if let flight = selectedFlight {
                        Picker("Выберите дату", selection: $selectedDate) {
                            Text(flight.departureDate).tag(flight.departureDate)
                        }
                    }
                }
            }

            if let result = registrationResult {
                Text(result)
                    .foregroundColor(result.contains("успешно") ? .green : .red)
                    .padding()
            }

            HStack {
                Button("Закрыть") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)

                Spacer()

                Button("Зарегистрировать пассажира") {
                    if let flight = selectedFlight {
                        registerPassenger(for: flight)
                    }
                }
                .disabled(
                    selectedFlight == nil ||
                    selectedDate.isEmpty ||
                    firstName.isEmpty ||
                    lastName.isEmpty ||
                    passportNumber.isEmpty ||
                    contactPhone.isEmpty
                )
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 20)
        }
        .onAppear {
            flightModel.loadFlights()
        }
        .padding()
    }

    func registerPassenger(for flight: Flight) {
        guard flight.availableSeats > 0 else {
            withAnimation {
                registrationResult = "Нет свободных мест на рейсе \(flight.flightNumber)"
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation {
                    registrationResult = nil
                }
            }
            return
        }

        // Обновляем количество мест
        let newSeats = flight.availableSeats - 1
        FlightsManager().updateAvailableSeats(for: flight.flightNumber, to: newSeats)

        // Добавляем пассажира
        PassengersManager().addPassenger(
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: DateFormatter.localizedString(from: dateOfBirth, dateStyle: .short, timeStyle: .none),
            passportNumber: passportNumber,
            contactPhone: contactPhone,
            flightNumber: flight.flightNumber
        )

        withAnimation {
            registrationResult = "Пассажир успешно зарегистрирован на рейс \(flight.flightNumber)"
            flightModel.loadFlights()
        }
        resetForm()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                registrationResult = nil
            }
        }
    }
    
    private func resetForm() {
        firstName = ""
        lastName = ""
        dateOfBirth = Date()
        passportNumber = ""
        contactPhone = ""
        selectedFlight = nil
    }
}

#Preview {
    let sampleFlights = [
        Flight(
            flightNumber: "SU123",
            airportId: "SVO",
            departureFrom: "Москва",
            departureDate: "2024-12-01",
            departureTime: "10:30",
            airportArrivalId: "JFK",
            arrival: "Нью-Йорк",
            arrivalDate: "2024-12-01",
            arrivalTime: "14:00",
            availableSeats: 20
        ),
        Flight(
            flightNumber: "BA456",
            airportId: "LHR",
            departureFrom: "Лондон",
            departureDate: "2024-12-02",
            departureTime: "15:00",
            airportArrivalId: "DXB",
            arrival: "Дубай",
            arrivalDate: "2024-12-02",
            arrivalTime: "23:30",
            availableSeats: 10
        )
    ]

    let flightModel = FlightModel()
    flightModel.allFlights = sampleFlights

    return RegisterPassengerView(flightModel: flightModel)
}
