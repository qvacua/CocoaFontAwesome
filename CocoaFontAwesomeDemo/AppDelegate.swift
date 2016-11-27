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
      let dummy = Dummy(frame: CGRect(x: 50, y: 50, width: 22, height: 22))
      dummy.wantsLayer = true
      dummy.layer?.backgroundColor = NSColor.yellow.cgColor

      contentView.addSubview(dummy)
    }
  }

  class Dummy: NSView {

    let image = NSImage.fontAwesomeIcon(name: .close,
                                        textColor: .black,
                                        dimension: 18)

    override func draw(_ dirtyRect: NSRect) {
      image.draw(in: CGRect(x: 2, y: 2, width: 18, height: 18))
    }
  }
