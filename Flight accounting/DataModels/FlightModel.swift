//
//  FlightModel.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 20.11.2024.
//

import Foundation

class FlightModel: ObservableObject {
    @Published var departures: [Flight] = []
    @Published var arrivals: [Flight] = []
    @Published var allFlights: [Flight] = []
    @Published var userName: String = "User"
    
    private let flightManager = FlightsManager()
    private let userManager = UsersManager()
    
    init() {
        print("Инициализация FlightModel")
        loadDepartures(from: "SVO")
        loadArrivals(to: "SVO")
        loadFlights()
        
        print("Загруженные рейсы: \(departures)")
        print("Загруженные рейсы: \(arrivals)")
        print("Загруженные рейсы: \(allFlights)")
        
    }
    
    func loadDepartures(from airportCode: String) {
        departures = flightManager.fetchDepartures(from: airportCode)
    }
    
    func loadArrivals(to airportCode: String) {
        arrivals = flightManager.fetchArrivals(to: airportCode)
    }
    
    func loadFlights() {
        allFlights = flightManager.fetchAllFlights()
    }
    
    func loadFlight(by flightNumber: String, on date: String) -> Flight? {
        return allFlights.first { $0.flightNumber == flightNumber && $0.departureDate == date }
    }
    
    func saveFlight(_ flight: Flight) {
        if let index = allFlights.firstIndex(where: { $0.flightNumber == flight.flightNumber && $0.departureDate == flight.departureDate }) {
            allFlights[index] = flight
        }
    }
    
    func deleteFlight(_ flight: Flight) {
        allFlights.removeAll { $0.flightNumber == flight.flightNumber && $0.departureDate == flight.departureDate }
    }
    
    
    
    
    func getUserName(for userLogin: String) {
        userName = userManager.getUser(byLogin: userLogin)
        print("Имя \(userName)")
    }
    
    func checkUser(login: String, password: String) -> Bool {
        if userManager.authenticateUser(login: login, password: password) {
            userName = userManager.getUser(byLogin: login) // Получаем имя пользователя после успешной аутентификации
            return true
        } else {
            return false
        }
    }
    
    func addUser(name: String, login: String, password: String) {
        userManager.addUser(name: name, login: login, password: password)
    }
}

extension FlightModel {
    func loadSortedFlights<T: Comparable>(by keyPath: KeyPath<Flight, T>, ascending: Bool) {
        let manager = FlightsManager()
        allFlights = manager.fetchAllFlightsSorted(by: keyPath, ascending: ascending)
    }
}
