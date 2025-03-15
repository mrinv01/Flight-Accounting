//
//  WindowSizeModifier.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 18.10.2024.
//

import SwiftUI

// Модификатор для управления размером окна
struct WindowSizeModifier: ViewModifier {
    let width: CGFloat
    let height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(WindowAccessor { window in
                window?.setContentSize(NSSize(width: width, height: height))
            })
    }
}

// Помощник для получения доступа к NSWindow
struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow?) -> ()

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                self.callback(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

// Упрощенная функция для использования модификатора размера окна
extension View {
    func windowSize(width: CGFloat, height: CGFloat) -> some View {
        self.modifier(WindowSizeModifier(width: width, height: height))
    }
}

