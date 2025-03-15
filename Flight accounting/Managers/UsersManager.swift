//
//  UsersManager.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 22.11.2024.
//

import Foundation
import SQLite
import CryptoKit

struct User: Identifiable {
    let id = UUID()
    var userName: String
    var userLogin: String
    var userPassword: String
}

class UsersManager {
    private let db = DatabaseManager.shared.getConnection()
    private let usersTable = Table("Users")
    
    private let userId = SQLite.Expression<Int64>("user_id")
    private let userName = SQLite.Expression<String>("user_name")
    private let userLogin = SQLite.Expression<String>("user_login")
    private let userPassword = SQLite.Expression<String>("user_password")
    
    
    func hashString(_ input: String) -> String {
        let inputData = Data(input.utf8) // Преобразуем строку в данные
        let hashedData = SHA256.hash(data: inputData) // Хэшируем данные
        return hashedData.compactMap { String(format: "%02x", $0) }.joined() // Преобразуем байты в строку
    }
    
    
    func authenticateUser(login: String, password: String) -> Bool {
        let hashedLogin = hashString(login)
        let hashedPassword = hashString(password)
        
        do {
            if let userRow = try db.pluck(usersTable.filter(self.userLogin == hashedLogin && self.userPassword == hashedPassword)) {
                print("Аутентификация успешна для пользователя: \(userRow[userName])")
                return true
            } else {
                print("Неверный логин или пароль")
                return false
            }
        } catch {
            print("Ошибка аутентификации: \(error)")
            return false
        }
    }
    
    
    func addUser(name: String, login: String, password: String) {
        let hashedLogin = hashString(login)
        let hashedPassword = hashString(password)
        
        let insert = usersTable.insert(
            self.userName <- name,
            self.userLogin <- hashedLogin,
            self.userPassword <- hashedPassword
        )
        
        do {
            try db.run(insert)
            print("Пользователь добавлен успешно")
        } catch {
            print("Ошибка при добавлении пользователя: \(error)")
        }
    }
    
    func getUser(byLogin login: String) -> String {
        let hashedLogin = hashString(login)
        do {
            if let userRow = try db.pluck(usersTable.filter(userLogin == hashedLogin)) {
                return userRow[userName]
            }
        } catch {
            print("Ошибка при извлечении пользователя: \(error)")
        }
        return "Пользователь"
    }
}

