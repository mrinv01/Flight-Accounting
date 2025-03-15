//
//  FlightSearchView.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 25.11.2024.
//

import SwiftUI

struct FlightSearchView: View {
    @ObservedObject var flightModel: FlightModel // Модель данных для интерфейса
    private let flightsManager = FlightsManager() // Менеджер работы с БД
    
    @State private var selectedCity: String? = nil // Выбранный город
    @State private var filteredFlights: [Flight] = [] // Отфильтрованные рейсы
    @State private var availableCities: [String] = [] // Уникальные пункты назначения

    var body: some View {
        VStack {
            Text("Поиск рейсов по пункту прибытия")
                .font(.title2)
                .padding()

            // Выпадающий список для выбора города назначения
            Picker("Город назначения", selection: $selectedCity) {
                Text("Выберите город").tag(nil as String?)
                ForEach(availableCities, id: \.self) { city in
                    Text(city).tag(city as String?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedCity) { _ in
                filterFlights()
            }
            .padding(.horizontal)

            // Таблица с результатами
            Table(filteredFlights) {
                TableColumn("Номер рейса", value: \.flightNumber)
                TableColumn("Дата вылета") { flight in
                    Text(flight.departureDate)
                }
                TableColumn("Время вылета") { flight in
                    Text(flight.departureTime)
                }
            }
            .padding()
        }
        .onAppear {
            loadCities()
        }
    }

    // Функция для загрузки уникальных городов
    private func loadCities() {
        availableCities = flightsManager.fetchUniqueArrivals()
    }

    // Фильтрация рейсов по выбранному городу назначения
    private func filterFlights() {
        if let city = selectedCity {
            filteredFlights = flightModel.allFlights.filter { $0.arrival == city }
        } else {
            filteredFlights = []
        }
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
        ),
        Flight(
            flightNumber: "AF789",
            airportId: "CDG",
            departureFrom: "Париж",
            departureDate: "2024-12-03",
            departureTime: "09:00",
            airportArrivalId: "JFK",
            arrival: "Нью-Йорк",
            arrivalDate: "2024-12-03",
            arrivalTime: "12:30",
            availableSeats: 5
        )
    ]
    
    let flightModel = FlightModel()
    flightModel.allFlights = sampleFlights
    
    return FlightSearchView(flightModel: flightModel)
}
