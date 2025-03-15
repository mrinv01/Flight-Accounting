//
//  PassengersView.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 25.11.2024.
//

import SwiftUI

struct PassengersView: View {
    @State private var selectedFlightNumber: String? = nil // Выбранный рейс
    @State private var flights: [Flight] = [] // Доступные рейсы
    @State private var passengers: [Passenger] = [] // Список пассажиров
    @Environment(\.presentationMode) var presentationMode
    
    private let flightsManager = FlightsManager() // Менеджер рейсов
    private let passengersManager = PassengersManager() // Менеджер пассажиров
    
    var body: some View {
        VStack {
            Text("Отчет по пассажирам").font(.title2).foregroundStyle(Color.gray)
                .padding(.top, 20)
            
            // Выпадающий список рейсов
            HStack {
                Picker("Выберите рейс", selection: $selectedFlightNumber) {
                    Text("Нет рейса").tag(nil as String?) // Пустой выбор
                    ForEach(flights, id: \.flightNumber) { flight in
                        Text("\(flight.flightNumber) (\(flight.arrival))")
                            .tag(flight.flightNumber as String?)
                    }
                }
                .onChange(of: selectedFlightNumber) { _ in
                    loadPassengers() // Обновить список пассажиров при изменении рейса
                }
                .frame(width: 400)
                
                Button("Закончить просмотр") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
            
            Spacer()
            
            // Таблица пассажиров
            if !passengers.isEmpty {
                Table(passengers) {
                    TableColumn("Имя", value: \.firstName)
                    TableColumn("Фамилия", value: \.lastName)
                    TableColumn("Дата рождения") { passenger in
                        Text(passenger.dateOfBirth)
                    }
                    TableColumn("Паспорт") { passenger in
                        Text(passenger.passportNumber)
                    }
                    TableColumn("Телефон") { passenger in
                        Text(passenger.contactPhone)
                    }
                }
                .padding()
                
            } else {
                Text("Пассажиры для этого рейса не найдены")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .onAppear {
            loadFlights() // Загрузка рейсов при отображении
        }
        .frame(width: 700, height: 500)
    }
    
    // Загрузка доступных рейсов
    private func loadFlights() {
        flights = flightsManager.fetchAllFlights()
        print("Loaded flights: \(flights)") // Отладка
    }
    
    // Загрузка пассажиров для выбранного рейса
    private func loadPassengers() {
        if let flightNumber = selectedFlightNumber {
            passengers = passengersManager.fetchPassengers(by: flightNumber)
            print("Loaded passengers for flight \(flightNumber): \(passengers)") // Отладка
        } else {
            passengers = []
            print("No flight selected")
        }
    }
}

#Preview {
    PassengersView()
}

