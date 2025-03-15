//
//  Aircrafts.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 20.11.2024.
//

import Foundation

class AircraftModel: ObservableObject {
    @Published var allAircrafts: [Aircraft] = []

    func loadAircrafts() {
        // Загрузка данных о самолетах из базы данных
        self.allAircrafts = AircraftsManager().fetchAircrafts()
    }
}
