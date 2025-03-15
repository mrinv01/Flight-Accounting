//
//  FlightsManager.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 20.11.2024.
//

import Foundation
import SQLite

struct Flight: Identifiable, Hashable {
    let id = UUID()
    var flightNumber: String
    var airportId: String
    var departureFrom: String
    var departureDate: String
    var departureTime: String
    var airportArrivalId: String
    var arrival: String
    var arrivalDate: String
    var arrivalTime: String
    var availableSeats: Int
}

class FlightsManager {
    let db = DatabaseManager.shared.getConnection()
    let flightsTable = Table("Flights")
    
    // Поля таблицы Flights
    private let flightNumber = SQLite.Expression<String>("flight_number")
    private let airportId = SQLite.Expression<String>("airport_dep_id")
    private let departureFrom = SQLite.Expression<String>("departure_from")
    private let departureDate = SQLite.Expression<String>("departure_date")
    private let departureTime = SQLite.Expression<String>("departure_time")
    private let airportArrivalId = SQLite.Expression<String>("airport_arrival_id")
    private let arrival = SQLite.Expression<String>("arrival")
    private let arrivalDate = SQLite.Expression<String>("arrival_date")
    private let arrivalTime = SQLite.Expression<String>("arrival_time")
    let availableSeats = SQLite.Expression<Int>("available_seats")
    
    init() {
        createTableIfNeeded()
    }
    
    private func createTableIfNeeded() {
        do {
            try db.run(flightsTable.create(ifNotExists: true) { table in
                table.column(flightNumber, primaryKey: true)
                table.column(airportId)
                table.column(departureFrom)
                table.column(departureDate)
                table.column(departureTime)
                table.column(airportArrivalId)
                table.column(arrival)
                table.column(arrivalDate)
                table.column(arrivalTime)
                table.column(availableSeats)
            })
        } catch {
            print("Ошибка при создании таблицы Flights: \(error)")
        }
    }
    
    func addFlight(_ flight: Flight) {
            do {
                try db.run(flightsTable.insert(
                    flightNumber <- flight.flightNumber,
                    departureFrom <- flight.departureFrom,
                    airportId <- flight.airportId,
                    departureDate <- flight.departureDate,
                    departureTime <- flight.departureTime,
                    airportArrivalId <- flight.airportArrivalId,
                    arrival <- flight.arrival,
                    arrivalDate <- flight.arrivalDate,
                    arrivalTime <- flight.arrivalTime,
                    availableSeats <- flight.availableSeats
                ))
            } catch {
                print("Error adding flight: \(error)")
            }
        }
    
    func fetchAllFlights() -> [Flight] {
        do {
            return try db.prepare(flightsTable).map { row in
                Flight(
                    flightNumber: row[flightNumber],
                    airportId: row[airportId],
                    departureFrom: row[departureFrom],
                    departureDate: row[departureDate],
                    departureTime: row[departureTime],
                    airportArrivalId: row[airportArrivalId],
                    arrival: row[arrival],
                    arrivalDate: row[arrivalDate],
                    arrivalTime: row[arrivalTime],
                    availableSeats: row[availableSeats]
                )
            }
        } catch {
            print("Ошибка при выборке рейсов: \(error)")
            return []
        }
    }
    
    func fetchDepartures(from airport: String) -> [Flight] {
        do {
            let query = flightsTable.filter(airportId == airport)
            return try db.prepare(query).map { row in
                Flight(
                    flightNumber: row[flightNumber],
                    airportId: row[airportId],
                    departureFrom: row[departureFrom],
                    departureDate: row[departureDate],
                    departureTime: row[departureTime],
                    airportArrivalId: row[airportArrivalId],
                    arrival: row[arrival],
                    arrivalDate: row[arrivalDate],
                    arrivalTime: row[arrivalTime],
                    availableSeats: row[availableSeats]
                )
            }
        } catch {
            print("Ошибка при выборке рейсов: \(error)")
            return []
        }
    }
    
    func fetchArrivals(to airport: String) -> [Flight] {
        do {
            let query = flightsTable.filter(airportArrivalId == airport)
            return try db.prepare(query).map { row in
                Flight(
                    flightNumber: row[flightNumber],
                    airportId: row[airportId],
                    departureFrom: row[departureFrom],
                    departureDate: row[departureDate],
                    departureTime: row[departureTime],
                    airportArrivalId: row[airportArrivalId],
                    arrival: row[arrival],
                    arrivalDate: row[arrivalDate],
                    arrivalTime: row[arrivalTime],
                    availableSeats: row[availableSeats]
                )
            }
        } catch {
            print("Ошибка при выборке рейсов: \(error)")
            return []
        }
    }
    
    
    func fetchAllFlightsSorted<T: Comparable>(by keyPath: KeyPath<Flight, T>, ascending: Bool) -> [Flight] {
        do {
            // Сопоставление KeyPath с выражением SQLite
            let query: Table
            
            if keyPath == \Flight.flightNumber {
                query = flightsTable.order(ascending ? flightNumber.asc : flightNumber.desc)
            } else if keyPath == \Flight.departureFrom {
                query = flightsTable.order(ascending ? departureFrom.asc : departureFrom.desc)
            } else if keyPath == \Flight.departureTime {
                query = flightsTable.order(ascending ? departureTime.asc : departureTime.desc)
            } else if keyPath == \Flight.arrival {
                query = flightsTable.order(ascending ? arrival.asc : arrival.desc)
            } else if keyPath == \Flight.arrivalTime {
                query = flightsTable.order(ascending ? arrivalTime.asc : arrivalTime.desc)
            } else if keyPath == \Flight.availableSeats {
                query = flightsTable.order(ascending ? availableSeats.asc : availableSeats.desc)
            } else {
                return fetchAllFlights() // Если ключ не найден, возвращаем данные без сортировки
            }
            
            // Выполняем запрос и преобразуем результаты
            return try db.prepare(query).map { row in
                Flight(
                    flightNumber: row[flightNumber],
                    airportId: row[airportId],
                    departureFrom: row[departureFrom],
                    departureDate: row[departureDate],
                    departureTime: row[departureTime],
                    airportArrivalId: row[airportArrivalId],
                    arrival: row[arrival],
                    arrivalDate: row[arrivalDate],
                    arrivalTime: row[arrivalTime],
                    availableSeats: row[availableSeats]
                )
            }
        } catch {
            print("Ошибка при выборке рейсов с сортировкой: \(error)")
            return []
        }
    }

    func updateFlight(_ updatedFlight: Flight) {
        do {
            let flight = flightsTable.filter(flightNumber == updatedFlight.flightNumber)
            try db.run(flight.update(
                airportId <- updatedFlight.airportId,
                departureFrom <- updatedFlight.departureFrom,
                departureDate <- updatedFlight.departureDate,
                departureTime <- updatedFlight.departureTime,
                airportArrivalId <- updatedFlight.airportArrivalId,
                arrival <- updatedFlight.arrival,
                arrivalDate <- updatedFlight.arrivalDate,
                arrivalTime <- updatedFlight.arrivalTime,
                availableSeats <- updatedFlight.availableSeats
            ))
            print("Рейс \(updatedFlight.flightNumber) успешно обновлен")
        } catch {
            print("Ошибка при обновлении рейса: \(error)")
        }
    }
    
    func deleteFlight(by flightNumber: String, departureDate: String) {
        do {
            let flight = flightsTable.filter(self.flightNumber == flightNumber && self.departureDate == departureDate)
            try db.run(flight.delete())
            print("Рейс \(flightNumber) успешно удален")
        } catch {
            print("Ошибка при удалении рейса: \(error)")
        }
    }
    
    func deleteData() {
        do {
            try db.run(flightsTable.delete())
        } catch {
            print("Ошибка при удалении данных \(error)")
        }
    }
    
    func fetchFlight(by flightNumber: String, at departureDate: String) -> Flight? {
        do {
            let query = flightsTable.filter(self.flightNumber == flightNumber && self.departureDate == departureDate)
            if let row = try db.pluck(query) {
                return Flight(
                    flightNumber: row[self.flightNumber],
                    airportId: row[self.airportId],
                    departureFrom: row[self.departureFrom],
                    departureDate: row[self.departureDate],
                    departureTime: row[self.departureTime],
                    airportArrivalId: row[self.airportArrivalId],
                    arrival: row[self.arrival],
                    arrivalDate: row[self.arrivalDate],
                    arrivalTime: row[self.arrivalTime],
                    availableSeats: row[self.availableSeats]
                )
            }
        } catch {
            print("Ошибка при загрузке рейса: \(error)")
        }
        return nil
    }


    
    func updateAvailableSeats(for flightNumber: String, to newAvailableSeats: Int) {
        do {
            let flight = flightsTable.filter(self.flightNumber == flightNumber)
            try db.run(flight.update(availableSeats <- newAvailableSeats))
            print("Обновлено количество мест на рейсе \(flightNumber) до \(newAvailableSeats)")
        } catch {
            print("Ошибка обновления количества мест: \(error)")
        }
    }
    
    func updateAllFlightsSeats(to seats: Int) {
            do {
                try db.run(flightsTable.update(availableSeats <- seats))
                print("Количество мест во всех рейсах обновлено до \(seats).")
            } catch {
                print("Ошибка при обновлении количества мест: \(error)")
            }
        }
    
    func fetchUniqueArrivals() -> [String] {
        do {
            // Используем group для получения уникальных пунктов назначения
            let query = flightsTable.select(arrival).group(arrival)
            let arrivals = try db.prepare(query)
            return arrivals.map { $0[arrival] }
        } catch {
            print("Ошибка при выборке уникальных пунктов назначения: \(error)")
            return []
        }
    }

    
}
