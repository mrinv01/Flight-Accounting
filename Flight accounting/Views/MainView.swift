//
//  mainView.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 18.10.2024.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var flight: FlightModel
    @ObservedObject var aircraft: AircraftModel
    @Binding var isAuthenticated: Bool
    var windowController: WindowController? // Ссылка на контроллер окна
    
    @State private var selectedSortColumnName: String? = nil
    @State private var isAscending: Bool = true // Направление сортировки
    @State private var hideNightFlights: Bool = false
    @State private var currentTime: String = ""
    @State private var currentDate: String = ""
    
    var selectedSortColumn: SortColumn? {
        guard let name = selectedSortColumnName else { return nil }
        return sortableColumns.first(where: { $0.name == name })
    }
    
    
    
    
    // Определение доступных для сортировки столбцов
    let sortableColumns: [SortColumn] = [
        SortColumn(name: "Номер рейса", keyPath: \Flight.flightNumber),
        SortColumn(name: "Пункт вылета", keyPath: \Flight.departureFrom),
        SortColumn(name: "Время вылета", keyPath: \Flight.departureTime),
        SortColumn(name: "Пункт прибытия", keyPath: \Flight.arrival),
        SortColumn(name: "Время прибытия", keyPath: \Flight.arrivalTime),
        SortColumn(name: "Свободные места", keyPath: \Flight.availableSeats)
    ]
    
    var body: some View {
        HStack {
            Text("Учет рейсов авиакомпании")
                .font(.title2)
                .padding(.leading, 20)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                HStack {
                    Text(currentDate).padding(.trailing, 5)
                    Text(currentTime).padding(.trailing, 10).onAppear(perform: startTimer)
                }
                HStack {
                    Text("\(flight.userName)")
                    Image(systemName: "poweron")
                        .backgroundStyle(Color.blue)
                    
                    Button (action: {
                        isAuthenticated.toggle()
                    }, label: {
                        HStack {
                            Image(systemName: "power")
                            Text("Выход")
                        }
                    })
                    .buttonStyle(.plain)
                    .padding(.trailing, 10)
                }
                .padding(.top, 1)
            }
        }
        .padding(.top, 20)
        
        HStack {
            VStack(alignment: .leading) {
                
                // Элементы управления сортировкой
                HStack {
                    Picker("Сортировать по", selection: $selectedSortColumnName) {
                        Text("Нет сортировки").tag(nil as String?) // Поддержка пустого выбора
                        ForEach(sortableColumns) { column in
                            Text(column.name).tag(column.name) // Сопоставление по имени
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 370)
                    
                    Toggle(isOn: $isAscending) {
                        Text(isAscending ? "По возрастанию" : "По убыванию")
                    }
                    .toggleStyle(SwitchToggleStyle())
                    
                    Spacer()
                    
                    Toggle(isOn: $hideNightFlights) {
                        Text("Ночные рейсы")
                    }
                }
                .padding(.leading, 20).padding(.top, 30)
                
                
                // Таблица с рейсами
                Table(filteredFlights()) {
                    TableColumn("Номер рейса", value: \.flightNumber)
                    TableColumn("Пункт вылета") { flight in
                        Text(flight.departureFrom)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    TableColumn("Время вылета", value: \.departureTime)
                    TableColumn("Пункт прибытия") { flight in
                        Text(flight.arrival)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    TableColumn("Время прибытия", value: \.arrivalTime)
                    TableColumn("Места") { flight in
                        Text("\(flight.availableSeats)")
                    }
                }
                .frame(width: 650)
                .padding(.leading, 20)
                .onChange(of: selectedSortColumn) { _ in applySorting() }
                .onChange(of: isAscending) { _ in applySorting() }
                
                
                Spacer()
                
            }
            .onAppear {
                windowController?.setWindowSize(width: 1100, height: 600) // Устанавливаем размер окна
                applySorting() // Применить сортировку при загрузке
            }
            Spacer()
            
            Buttons(flight: flight, aircraft: aircraft)
            
            Spacer()
            
        }
        .frame(minWidth: 1100, minHeight: 600)
        
    }
    
    // Применение сортировки к данным
    private func applySorting() {
        guard let column = selectedSortColumn else {
            flight.loadFlights()
            return
        }
        
        if column.isString {
            guard let keyPath = column.keyPath as? KeyPath<Flight, String> else { return }
            flight.loadSortedFlights(by: keyPath, ascending: isAscending)
        } else {
            guard let keyPath = column.keyPath as? KeyPath<Flight, Int> else { return }
            flight.loadSortedFlights(by: keyPath, ascending: isAscending)
        }
    }
    
    // Фильтрация ночных рейсов
        private func applyFiltering() {
            flight.loadFlights()
        }

    // Функция для получения фильтрованных рейсов
        private func filteredFlights() -> [Flight] {
            if hideNightFlights {
                return flight.allFlights.filter { flight in
                    guard let hour = parseTime(flight.departureTime) else { return true }
                    return !(hour >= 23 || hour < 3) // Убираем рейсы с 23:00 до 3:00
                }
            }
            return flight.allFlights
        }

        // Парсер времени в формат часа (Int)
        private func parseTime(_ timeString: String) -> Int? {
            let components = timeString.split(separator: ":")
            guard components.count == 2, let hour = Int(components[0]) else {
                return nil
            }
            return hour
        }
    
    
    private func startTimer() {
        // Устанавливаем начальное значение времени
        currentTime = getTime()
        currentDate = getDate()
        
        // Запускаем таймер для обновления каждую секунду
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentTime = getTime()
        }
        // Запускаем таймер для обновления каждый час
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            currentDate = getDate()
        }
    }
    
    private func getTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        return minute < 10 ? "\(hour):0\(minute)" : "\(hour):\(minute)"
    }
    
    private func getDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
}

// Модель для столбцов сортировки
struct SortColumn: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let keyPath: AnyKeyPath // Используем AnyKeyPath для универсальности
    let isString: Bool
    
    init<T: Comparable>(name: String, keyPath: KeyPath<Flight, T>) {
        self.name = name
        self.keyPath = keyPath
        self.isString = T.self == String.self
    }
}


#Preview {
    @Previewable @State var isAuthenticated = true
    @Previewable @State var isGuest = false
    
    let testFlights = [
        Flight(
            flightNumber: "SU-1234",
            airportId: "SVX",
            departureFrom: "Екатеринбург",
            departureDate: "2024-11-21",
            departureTime: "10:00",
            airportArrivalId: "SVO",
            arrival: "Москва",
            arrivalDate: "2024-11-21",
            arrivalTime: "12:00",
            availableSeats: 50
        ),
        Flight(
            flightNumber: "SU-5678",
            airportId: "SVX",
            departureFrom: "Екатеринбург",
            departureDate: "2024-12-05",
            departureTime: "15:00",
            airportArrivalId: "LED",
            arrival: "Санкт-Петербург",
            arrivalDate: "2024-12-05",
            arrivalTime: "17:30",
            availableSeats: 30
        )
    ]
    
    let testModel = FlightModel()
    testModel.allFlights = testFlights
    
    return MainView(flight: testModel, aircraft: AircraftModel(), isAuthenticated: $isAuthenticated)
}
