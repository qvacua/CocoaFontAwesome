//
//  AppDelegate.swift
//  CocoaFontAwesomeDemo
//
//  Created by Tae Won Ha on 27/11/2016.
//  Copyright © 2016 Tae Won Ha. All rights reserved.
//

import Cocoa
import CocoaFontAwesome

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentView = self.window.contentView!
        let image = NSImage.fontAwesomeIcon(code: "fa-times-circle",
                                            style: .regular,
                                            textColor: .darkGray,
                                            dimension: 16)
        let button = NSButton(frame: CGRect(x: 50, y: 50, width: 40, height: 40))
        button.imagePosition = .imageOnly
        button.image = image
        button.isBordered = false

        // The following disables the square appearing when pushed.
        let cell = button.cell as? NSButtonCell
        cell?.highlightsBy = .contentsCellMask
        cell?.backgroundColor = .yellow

        contentView.addSubview(button)
    }
}

class Dummy: NSView {

    let image = NSImage.fontAwesomeIcon(name: .windowClose,
                                        style: .regular,
                                        textColor: .black,
                                        dimension: 18)

    override func draw(_ dirtyRect: NSRect) {
        image.draw(in: CGRect(x: 2, y: 2, width: 18, height: 18))
    }
}
