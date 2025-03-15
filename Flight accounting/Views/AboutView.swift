//
//  AboutView.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 18.10.2024.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismissWindow) private var dismissWindow
    var body: some View {
        HStack {
            Image("Plane")
                .resizable()
                .scaledToFit()
            
            Spacer().frame(width: 30)
            
            VStack(alignment: .leading) {
                
                Text("Учет рейсов авиакомпании")
                    .font(.system(size: 15) .weight(.semibold))
                
                Text("Версия программы: v1.0.1_10190114")
                
                    .padding(.top, 25)
                
                Text("Разработчик: Ильютченко Никита Витальевич")
                    .padding(.top, 10)
                Text("Дата выпуска: 21 ноября 2024г.")
                    .padding(.top, 10)
                
                Text("Программное средство 'Учет рейсов авиакомпинии' разработано для отслеживания рейсов авиакомпанни, добавления новых рейсов, а также редактирования уже существующих.")
                    .padding(.top, 30)
                
                Spacer()
                
                
                Button(action:{
                    dismissWindow(id: "about")
                }){
                    Text("Закрыть")
                }
                .padding(.top, 30)
                
                Spacer()
            }
            .padding(.top, 35)
            Spacer()
        }
    }
}

#Preview {
    AboutView()
}

