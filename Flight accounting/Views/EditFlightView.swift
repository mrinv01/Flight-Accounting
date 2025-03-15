//
//  EditFlightView.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 24.11.2024.
//

import SwiftUI

struct EditFlightView: View {
    @ObservedObject var flightModel: FlightModel // Модель данных для интерфейса
    let flightsManager = FlightsManager() // Менеджер работы с БД
    
    @State private var selectedFlightNumber: String? = nil
    @State private var selectedDate: Date? = nil
    @State private var editableFlight: Flight? = nil
    @State private var showAlert: Bool = false
    @State private var alertMessage: String? = nil
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Редактирование рейса")
                .font(.title2)
                .foregroundStyle(Color.gray)
                .padding()
            
            VStack(alignment: .leading) {
                
                // Выбор номера рейса
                Picker("Номер рейса", selection: $selectedFlightNumber) {
                    Text("Выберите рейс").tag(nil as String?)
                    ForEach(flightModel.allFlights, id: \.self) { flight in
                        Text("\(flight.flightNumber) (\(flight.departureFrom) → \(flight.arrival))")
                            .tag(flight.flightNumber as String?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedFlightNumber) { _ in
                    clearSelections()
                }
                
                // Выбор даты рейса
                if let flightNumber = selectedFlightNumber {
                    Picker("Дата вылета", selection: $selectedDate) {
                        Text("Выберите дату").tag(nil as Date?)
                        ForEach(flightModel.allFlights.filter { $0.flightNumber == flightNumber }.map { $0.departureDateAsDate }, id: \.self) { date in
                            Text(dateFormatter.string(from: date)).tag(date as Date?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedDate) { _ in
                        editableFlight = nil
                    }
                }
                
                // Загрузка информации о рейсе
                if let flightNumber = selectedFlightNumber, let date = selectedDate {
                    Button("Загрузить рейс") {
                        editableFlight = flightsManager.fetchFlight(by: flightNumber, at: dateFormatter.string(from: date))
                    }
                    .padding(.vertical)
                }
                
                // Форма редактирования рейса
                if let flight = editableFlight {
                    Form {
                        TextField("Номер рейса", text: Binding(
                            get: { flight.flightNumber },
                            set: { editableFlight?.flightNumber = $0 }
                        ))
                        TextField("Пункт вылета", text: Binding(
                            get: { flight.departureFrom },
                            set: { editableFlight?.departureFrom = $0 }
                        ))
                        TextField("Код аэропорта вылета", text: Binding(
                            get: { flight.airportId },
                            set: { editableFlight?.airportId = $0 }
                        ))
                        TextField("Пункт прибытия", text: Binding(
                            get: { flight.arrival },
                            set: { editableFlight?.arrival = $0 }
                        ))
                        TextField("Код аэропорта прибытия", text: Binding(
                            get: { flight.airportArrivalId },
                            set: { editableFlight?.airportArrivalId = $0 }
                        ))
                        
                        // Дата и время вылета
                        DatePicker("Дата вылета", selection: Binding(
                            get: { flight.departureDateAsDate },
                            set: { editableFlight?.departureDate = dateFormatter.string(from: $0) }
                        ), displayedComponents: .date)
                        
                        DatePicker("Время вылета", selection: Binding(
                            get: { timeFormatter.date(from: flight.departureTime) ?? Date() },
                            set: { editableFlight?.departureTime = timeFormatter.string(from: $0) }
                        ), displayedComponents: .hourAndMinute)
                        
                        // Дата и время прилета
                        DatePicker("Дата прилета", selection: Binding(
                            get: { flight.arrivalDateAsDate },
                            set: { editableFlight?.arrivalDate = dateFormatter.string(from: $0) }
                        ), displayedComponents: .date)
                        
                        DatePicker("Время прилета", selection: Binding(
                            get: { timeFormatter.date(from: flight.arrivalTime) ?? Date() },
                            set: { editableFlight?.arrivalTime = timeFormatter.string(from: $0) }
                        ), displayedComponents: .hourAndMinute)
                        
                        TextField("Свободные места", value: Binding(
                            get: { flight.availableSeats },
                            set: { editableFlight?.availableSeats = $0 }
                        ), formatter: NumberFormatter())
                    }
                    
                    // Кнопки для сохранения или удаления рейса
                    HStack {
                        Button("Сохранить изменения") {
                            if let updatedFlight = editableFlight {
                                flightsManager.updateFlight(updatedFlight)
                                flightModel.loadFlights() // Обновление модели
                                alertMessage = "Изменения успешно сохранены для рейса \(updatedFlight.flightNumber)."
                                showAlert = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button(action: {
                            if let flightToDelete = editableFlight {
                                flightsManager.deleteFlight(by: flightToDelete.flightNumber, departureDate: flightToDelete.departureDate)
                                clearSelections()
                                alertMessage = "Рейс успешно удалён."
                                showAlert = true
                                flightModel.loadFlights()
                                flightModel.loadArrivals(to: "SVO")
                                flightModel.loadDepartures(from: "SVO")
                            }
                        }, label:{
                            HStack {
                                Image(systemName: "trash")
                                Text("Удалить рейс")
                            }.foregroundStyle(Color.red)
                        })
                        
                        Spacer()
                        
                        Button("Закрыть") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.red)
                        
                    }
                    .padding(.top, 20)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertMessage ?? ""),
                    dismissButton: .default(Text("ОК"))
                )
            }
            .padding()
        }
    }
    
    // Очистка всех выбранных данных
    private func clearSelections() {
        selectedDate = nil
        editableFlight = nil
    }
    
    // Форматтер для работы с датой
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}

extension Flight {
    // Преобразование даты и времени в объекты Date
    var departureDateAsDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: departureDate) ?? Date()
    }
    
    var arrivalDateAsDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: arrivalDate) ?? Date()
    }
}

#Preview {
    let sampleFlights = [
        Flight(
            flightNumber: "SU123",
            airportId: "SVO",
            departureFrom: "Москва",
            departureDate: "2024-12-01",
            departureTime: "10:30",
            airportArrivalId: "JFK",
            arrival: "Нью-Йорк",
            arrivalDate: "2024-12-01",
            arrivalTime: "14:00",
            availableSeats: 20
        ),
        Flight(
            flightNumber: "BA456",
            airportId: "LHR",
            departureFrom: "Лондон",
            departureDate: "2024-12-02",
            departureTime: "15:00",
            airportArrivalId: "DXB",
            arrival: "Дубай",
            arrivalDate: "2024-12-02",
            arrivalTime: "23:30",
            availableSeats: 10
        )
    ]
    
    let flightModel = FlightModel()
    flightModel.allFlights = sampleFlights
    
    return EditFlightView(flightModel: flightModel)
}

