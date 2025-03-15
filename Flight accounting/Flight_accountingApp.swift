//
//  Flight_accountingApp.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 17.10.2024.
//

import SwiftUI

import SwiftUI

@main
struct Flight_accountingApp: App {
    @State private var isAuthenticated = false
    @State private var isGuest = false
    
    @ObservedObject var flights = FlightModel()
    @ObservedObject var aircraft = AircraftModel()
    var windowController: WindowController?
    
    
    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                MainView(flight: flights, aircraft: aircraft, isAuthenticated: $isAuthenticated, windowController: windowController) // Передаем контроллер в основное окно
                    .onAppear {
                        windowController?.setWindowSize(width: 800, height: 600) // Устанавливаем размер для основного окна
                    }
                
            } else if isGuest {
                GuestView(isGuest: $isGuest)
            } else {
                LoginView(user: flights, isAuthenticated: $isAuthenticated, isGuest: $isGuest, windowController: windowController)
                    .windowSize(width: 600, height: 500)// Передаем контроллер в окно авторизации
            }
        }
        .windowStyle(DefaultWindowStyle())
        
        Window("О программе", id: "about") {
            AboutView()
        }
    }
}


