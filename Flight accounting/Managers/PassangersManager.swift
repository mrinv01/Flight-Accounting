//
//  PassengersView.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 23.11.2024.
//

import SQLite
import Foundation

struct Passenger: Identifiable, Hashable {
    let id = UUID()
    let firstName: String
    let lastName: String
    let dateOfBirth: String
    let passportNumber: String
    let contactPhone: String
    let flightNumber: String
}

class PassengersManager {
    private let db = DatabaseManager.shared.getConnection()
    private let passengersTable = Table("Passengers")
    
    // Поля таблицы Passengers
    private let id = SQLite.Expression<Int>("id")
    private let firstName = SQLite.Expression<String>("first_name")
    private let lastName = SQLite.Expression<String>("last_name")
    private let dateOfBirth = SQLite.Expression<String>("date_of_birth")
    private let passportNumber = SQLite.Expression<String>("passport_number")
    private let contactPhone = SQLite.Expression<String>("contact_phone")
    private let flightNumber = SQLite.Expression<String>("flight_number")
    
    init() {
        createTableIfNeeded()
    }
    
    private func createTableIfNeeded() {
        do {
            try db.run(passengersTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(firstName)
                table.column(lastName)
                table.column(dateOfBirth)
                table.column(passportNumber)
                table.column(contactPhone)
                table.column(flightNumber)
            })
        } catch {
            print("Ошибка при создании таблицы Passengers: \(error)")
        }
    }
    
    func addPassenger(firstName: String, lastName: String, dateOfBirth: String, passportNumber: String, contactPhone: String, flightNumber: String) {
        do {
            try db.run(passengersTable.insert(
                self.firstName <- firstName,
                self.lastName <- lastName,
                self.dateOfBirth <- dateOfBirth,
                self.passportNumber <- passportNumber,
                self.contactPhone <- contactPhone,
                self.flightNumber <- flightNumber
            ))
            print("Пассажир \(firstName) \(lastName) добавлен")
        } catch {
            print("Ошибка при добавлении пассажира: \(error)")
        }
    }
    
    func fetchPassengers(by flightNumber: String) -> [Passenger] {
        do {
            let query = passengersTable.filter(self.flightNumber == flightNumber)
            let result = try db.prepare(query).map { row in
                Passenger(
                    firstName: row[firstName],
                    lastName: row[lastName],
                    dateOfBirth: row[dateOfBirth],
                    passportNumber: row[passportNumber],
                    contactPhone: row[contactPhone],
                    flightNumber: row[self.flightNumber]
                )
            }
            print("Fetched passengers: \(result)") // Отладка
            return result
        } catch {
            print("Ошибка при выборке пассажиров: \(error)")
            return []
        }
    }

    
    func deleteData() {
        do {
            try db.run(passengersTable.delete())
        } catch {
            print("Ошибка при удалении данных \(error)")
        }
    }
}
