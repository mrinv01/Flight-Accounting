//
//  WindowController.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 18.10.2024.
//

import Foundation

import AppKit

class WindowController: NSWindowController {
    func setWindowSize(width: CGFloat, height: CGFloat) {
        self.window?.setContentSize(NSSize(width: width, height: height))
    }
}
