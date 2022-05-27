//
//  barclockApp.swift
//  barclock
//
//  Created by Chris McElroy on 5/18/22.
//

import SwiftUI

@main
struct barclockApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@ObservedObject var settings = Settings.main
	
    var body: some Scene {
        WindowGroup {
            ContentView()
		}
		
    }
}

// juicy shit https://stackoverflow.com/questions/64949572/how-to-create-status-bar-icon-menu-with-swiftui-like-in-macos-big-sur
// how i got the quit button, could be useful for other items in the future https://sarunw.com/posts/how-to-make-macos-menu-bar-app/

class StatusBarController {
	static var main: StatusBarController = StatusBarController()
	private var statusBar: NSStatusBar
	private var statusItem: NSStatusItem
	var minuteHandItem: NSMenuItem
	var dayModeItem: NSMenuItem
	
	init() {
		statusBar = NSStatusBar.init()
		// Creating a status bar item having a fixed length
		statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
		
		if let statusBarButton = statusItem.button {
			statusBarButton.image = NSImage(systemSymbolName: "circle.grid.2x1.fill", accessibilityDescription: "barclock")
//			statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
			statusBarButton.image?.isTemplate = true
		}
		
		// Add a menu and a menu item
		let menu = NSMenu()
		minuteHandItem = NSMenuItem(title: "minute hand", action: #selector(toggleMinuteHand), keyEquivalent: "")
		minuteHandItem.state = Settings.main.minuteHand ? .on : .off
		menu.addItem(minuteHandItem)
		dayModeItem = NSMenuItem(title: "24 hour mode", action: #selector(toggleDayMode), keyEquivalent: "")
		dayModeItem.state = Settings.main.dayMode ? .on : .off
		
		menu.addItem(dayModeItem)
		menu.addItem(NSMenuItem(title: "quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
		statusItem.menu = menu
		minuteHandItem.target = self // otherwise they're greyed out
		dayModeItem.target = self
	}
	
	@objc func toggleMinuteHand() {
		Settings.main.minuteHand.toggle()
		minuteHandItem.state = Settings.main.minuteHand ? .on : .off
	}
	
	@objc func toggleDayMode() {
		Settings.main.dayMode.toggle()
		dayModeItem.state = Settings.main.dayMode ? .on : .off
	}
}

class AppDelegate: NSObject, NSApplicationDelegate {
	var statusBar: StatusBarController?
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		if let window = NSApplication.shared.windows.first {
			window.titleVisibility = .hidden
			window.titlebarAppearsTransparent = true
			window.standardWindowButton(NSWindow.ButtonType.closeButton)!.isHidden = true
			window.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)!.isHidden = true
			window.standardWindowButton(NSWindow.ButtonType.zoomButton)!.isHidden = true
			window.isOpaque = false
			window.level = .floating
			window.backgroundColor = NSColor.clear
			window.isReleasedWhenClosed = false
			window.isMovableByWindowBackground = true
			window.collectionBehavior = .canJoinAllSpaces
		}
		
		//Initialising the status bar
		statusBar = StatusBarController.main
		return
	}
}
