//
//  DatabaseManager.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 20.11.2024.
//

import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection!

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        let fileManager = FileManager.default

        // Путь к базе данных в Bundle (ресурсы программы)
        guard let bundlePath = Bundle.main.path(forResource: "main_db", ofType: "db") else {
            print("Ошибка: база данных не найдена в Bundle")
            return
        }

        // Путь для сохранения базы данных в директории Documents
        let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let destinationPath = documentDirectory.appendingPathComponent("main_db.db")

        // Если база данных еще не скопирована, копируем ее
        if !fileManager.fileExists(atPath: destinationPath.path) {
            do {
                try fileManager.copyItem(atPath: bundlePath, toPath: destinationPath.path)
                print("База данных успешно скопирована в \(destinationPath.path)")
            } catch {
                print("Ошибка при копировании базы данных: \(error)")
            }
        } else {
            print("База данных уже существует по пути: \(destinationPath.path)")
        }

        // Подключаемся к базе данных
        do {
            db = try Connection(destinationPath.path)
            print("База данных подключена: \(destinationPath.path)")
        } catch {
            print("Ошибка при подключении к базе данных: \(error)")
        }
    }

    func getConnection() -> Connection {
        return db
    }
}
