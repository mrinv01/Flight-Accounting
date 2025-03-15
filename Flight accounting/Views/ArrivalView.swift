//
//  DepartureView.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 19.11.2024.
//

import SwiftUI

struct ArrivalView: View {
    @ObservedObject var flights: FlightModel
    @Binding var isGuest: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("Табло прилета")
                    .font(.title).fontWeight(.bold)
                    .padding(.top, 10)
                    .padding(.leading, 20)
                Spacer()
                Button(action: {
                    isGuest.toggle()
                }, label: {
                    Text("Выйти")
                })
                .padding(.top, 10)
                .padding(.trailing, 20)
            }
            List(flights.arrivals.indices, id: \.self) { index in
                let flight = flights.arrivals[index]
                if flights.arrivals.isEmpty {
                    Text("Нет рейсов")
                } else {
                    VStack(alignment: .leading) {
                        HStack {
                            Image("Aeroflot")
                                .resizable()
                                .scaleEffect(x: -1, y: 1)
                                .frame(width: 26, height: 20)
                            Text("\(flight.flightNumber)")
                                .font(.headline)
                        }
                        HStack {
                            Text("\(flight.departureFrom)")
                                .font(.title).fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("Прибытие в \(formattedTime(flight.arrivalTime))")
                                .font(.title).fontWeight(.semibold)
                        }
                        HStack(alignment: .top) {
                            Spacer()
                            Text("Вылетел \(formattedDate(flight.departureDate)), в \(formattedTime(flight.departureTime))")
                                .font(.subheadline)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        
        
    }
    
    // Функция для форматирования времени
    private func formattedTime(_ time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss" // Формат исходного времени
        if let date = formatter.date(from: time) {
            formatter.dateFormat = "HH:mm" // Новый формат без секунд
            return formatter.string(from: date)
        }
        return time // Если форматирование не удалось, вернуть исходное значение
    }
    
    // Функция для форматирования даты
    private func formattedDate(_ date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Формат исходной даты
        formatter.locale = Locale(identifier: "ru_RU") // Установка русской локали
        if let dateObj = formatter.date(from: date) {
            formatter.dateFormat = "dd MMMM" // Новый формат: число и месяц
            return formatter.string(from: dateObj)
        }
        return date // Если форматирование не удалось, вернуть исходное значение
    }
}

#Preview {
    // Создаем тестовые данные для предварительного просмотра
    @Previewable @State var isGuest: Bool = true
    // Создаем тестовые данные для предварительного просмотра
    let testFlights = [
        Flight(
            flightNumber: "SU1234",
            airportId: "SVX",
            departureFrom: "Екатеринбург",
            departureDate: "2024-11-21",
            departureTime: "10:00:00",
            airportArrivalId: "SVO",
            arrival: "Москва",
            arrivalDate: "2024-11-21",
            arrivalTime: "12:00:00",
            availableSeats: 50
        ),
        Flight(
            flightNumber: "SU5678",
            airportId: "LED",
            departureFrom: "Санкт-Петербург",
            departureDate: "2024-12-05",
            departureTime: "15:00:00",
            airportArrivalId: "SVO",
            arrival: "Москва",
            arrivalDate: "2024-12-05",
            arrivalTime: "17:30:00",
            availableSeats: 30
        )
    ]
    
    let testModel = FlightModel()
    testModel.departures = testFlights // Заполняем тестовые данные
    
    return ArrivalView(flights: testModel, isGuest: $isGuest)
}
