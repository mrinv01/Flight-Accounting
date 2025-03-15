//
//  AddAircraftView.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 25.11.2024.
//

import SwiftUI

struct AddAircraftView: View {
    @State private var model: String = ""
    @State private var capacity: String = ""
    @State private var lastMaintenance: String = ""
    @State private var status: String = ""
    @State private var showingAlert = false
    
    @Environment(\.presentationMode) var presentationMode

    let aircraftsManager = AircraftsManager()

    var body: some View {
        VStack {
            Text("Добавление воздушного судна").font(.title2).foregroundStyle(Color.gray)
                .padding(.bottom, 20)

            Form {
                TextField("Модель самолета", text: $model)

                TextField("Вместимость", text: $capacity)
                    
                TextField("Дата последнего обслуживания", text: $lastMaintenance)

                TextField("Статус", text: $status)
            }
            .frame(width: 400)
            
            HStack {
                Button("Закрыть") {
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                Button(action: {
                    if let capacityValue = Int(capacity) {
                        aircraftsManager.addAircraft(
                            model: model,
                            capacity: capacityValue,
                            lastMaintenance: lastMaintenance,
                            status: status
                        )
                        showingAlert = true
                    } else {
                        print("Ошибка: вместимость должна быть числом.")
                    }
                }) {
                    Text("Добавить самолет")
                }
                .buttonStyle(.borderedProminent)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Операция выполнена"), message: Text("Самолет успешно добавлен"), dismissButton: .default(Text("ОК")))
                }
            }
            .padding(.top, 30)

           
        }
        .frame(width: 400)
        .padding()
    }
}

#Preview {
    AddAircraftView()
}

