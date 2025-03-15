//
//  ClearDataView.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 25.11.2024.
//

import SwiftUI

struct ClearDataView: View {
    let flightsManager = FlightsManager()
    let passengersManager = PassengersManager()
    
    @ObservedObject var flight: FlightModel
    
    @State private var selectedTable: String? = nil
    @State private var confirmationText: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    private let tables = ["Passengers", "Flights"]

    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(Color.red)
                .font(.system(size: 80))
                .padding()
            Text("Предупреждение")
                .font(.title2).fontWeight(.semibold).padding(.top, 5)
            
            Text("Выполнив удаление, вы потеряете все данные, котрые содержатся в выбранной таблице. Данное действие необратимо, выполняйте его с осторожностью.")
                .multilineTextAlignment(.center)
                .frame(height: 50)
                .padding()
            // Выбор таблицы для очистки
            Picker("Выберите таблицу", selection: $selectedTable) {
                Text("Выберите таблицу").tag(nil as String?)
                ForEach(tables, id: \.self) { table in
                    Text(table).tag(table as String?)
                }
                
            }
            .frame(width: 400)
            .pickerStyle(MenuPickerStyle())
            
            TextField("\(flight.userName)", text: $confirmationText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 350)
                .padding(.top, 20)
                .disabled(
                    selectedTable == nil
                )
            Text("Введите свое имя для подтверждения операции")
                .font(.footnote).foregroundStyle(Color.gray)
            
            Spacer()

            HStack {
                Button("Закрыть") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
                Spacer()
                Button(action: {
                    if confirmationText == flight.userName {
                        performClearAction(for: selectedTable!)
                        flight.loadFlights()
                        flight.loadArrivals(to: "SVO")
                        flight.loadDepartures(from: "SVO")
                    } else {
                        alertMessage = "Неверное имя пользователя. Попробуйте снова."
                        showAlert = true
                    }
                }) {
                    Text("Стереть данные").foregroundStyle(Color.red)
                }
                .buttonStyle(.bordered)
                .disabled(
                    selectedTable == nil ||
                    confirmationText != flight.userName
                )
            }.padding(.top, 50)
            
            Spacer()
        
        }
        .frame(width: 500, height: 400)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Данные удалены"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .padding()
    }
    
    // Метод для выполнения очистки данных
    private func performClearAction(for table: String) {
        switch table {
        case "Passengers":
            passengersManager.deleteData()
            flightsManager.updateAllFlightsSeats(to: 250)
            alertMessage = "Все пассажиры удалены. Количество мест во всех рейсах установлено на 250."
        case "Flights":
            flightsManager.deleteData()
            alertMessage = "Все рейсы удалены."
        default:
            alertMessage = "Неизвестная таблица."
        }
        showAlert = true
        resetForm()
    }
    
    // Сброс формы
    private func resetForm() {
        selectedTable = nil
        confirmationText = ""
    }
}

#Preview {
    ClearDataView(flight: FlightModel())
}
