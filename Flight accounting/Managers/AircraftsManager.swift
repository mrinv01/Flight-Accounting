//
//  AircraftsManager.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 20.11.2024.
//

import Foundation
import SQLite

struct Aircraft: Identifiable, Hashable {
    let id = UUID()
    let model: String
    let capacity: Int
    let lastMaintenance: String
    let status: String
}

class AircraftsManager {
    private let db = DatabaseManager.shared.getConnection()
    private let aircraftsTable = Table("Aircrafts")

    // Поля таблицы
    private let model = SQLite.Expression<String>("model")
    private let capacity = SQLite.Expression<Int>("capacity")
    private let lastMaintenance = SQLite.Expression<String>("last_maintenance")
    private let status = SQLite.Expression<String>("status")

    init() {
        createTableIfNeeded()
    }

    private func createTableIfNeeded() {
        do {
            try db.run(aircraftsTable.create(ifNotExists: true) { table in
                table.column(model)
                table.column(capacity)
                table.column(lastMaintenance)
                table.column(status)
            })
        } catch {
            print("Ошибка при создании таблицы Aircrafts: \(error)")
        }
    }

    func addAircraft(model: String, capacity: Int, lastMaintenance: String, status: String) {
        do {
            let insert = aircraftsTable.insert(
                self.model <- model,
                self.capacity <- capacity,
                self.lastMaintenance <- lastMaintenance,
                self.status <- status
            )
            try db.run(insert)
            print("Самолет добавлен!")
        } catch {
            print("Ошибка при добавлении самолета: \(error)")
        }
    }

    func fetchAircrafts() -> [Aircraft] {
        do {
            var aircrafts: [Aircraft] = []
            for row in try db.prepare(aircraftsTable) {
                let aircraft = Aircraft(
                    model: row[model],
                    capacity: row[capacity],
                    lastMaintenance: row[lastMaintenance],
                    status: row[status]
                )
                aircrafts.append(aircraft)
            }
            return aircrafts
        } catch {
            print("Ошибка при получении самолетов: \(error)")
            return []
        }
    }
}
