//
//  barclockApp.swift
//  barclock
//
//  Created by Chris McElroy on 5/18/22.
//

import SwiftUI
import HotKey

@main
struct barclockApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@ObservedObject var settings = Settings.main
	
    var body: some Scene {
        WindowGroup {
			GeometryReader { geometry in
				ContentView()
					.edgesIgnoringSafeArea(.all)
					.onChange(of: geometry.size) { newSize in
						let widthSize = (newSize.width - 9)/(settings.minuteHand ? (4 + smallSize*3) : (3 + smallSize*2))
						let heightSize = settings.timer ? newSize.height/(2 + smallSize) : newSize.height
						let minSize = 6.0
						settings.size = max(minSize, min(widthSize, heightSize))
					}
			}
		}//.windowStyle(.hiddenTitleBar)
    }
}

// juicy shit https://stackoverflow.com/questions/64949572/how-to-create-status-bar-icon-menu-with-swiftui-like-in-macos-big-sur
// how i got the quit button, could be useful for other items in the future https://sarunw.com/posts/how-to-make-macos-menu-bar-app/

class StatusBarController {
	static var main: StatusBarController = StatusBarController()
	private var statusBar: NSStatusBar
	private var statusItem: NSStatusItem
	var clickThroughItem: NSMenuItem
	var minuteHandItem: NSMenuItem
	var dayModeItem: NSMenuItem
	var timerItem: NSMenuItem
//	let hotKey = HotKey(key: .t, modifiers: [.command, .option])
	
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
		clickThroughItem = NSMenuItem(title: "click through", action: #selector(toggleClickThrough), keyEquivalent: "")
		clickThroughItem.state = Settings.main.clickThrough ? .on : .off
		menu.addItem(clickThroughItem)
		minuteHandItem = NSMenuItem(title: "minute hand", action: #selector(toggleMinuteHand), keyEquivalent: "")
		minuteHandItem.state = Settings.main.minuteHand ? .on : .off
		menu.addItem(minuteHandItem)
		dayModeItem = NSMenuItem(title: "24 hour mode", action: #selector(toggleDayMode), keyEquivalent: "")
		dayModeItem.state = Settings.main.dayMode ? .on : .off
		menu.addItem(dayModeItem)
		timerItem = NSMenuItem(title: "timer", action: #selector(toggleTimer), keyEquivalent: "")
		timerItem.state = Settings.main.timer ? .on : .off
		menu.addItem(timerItem)
		menu.addItem(NSMenuItem(title: "quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
		statusItem.menu = menu
		clickThroughItem.target = self // otherwise they're greyed out
		minuteHandItem.target = self
		dayModeItem.target = self
		timerItem.target = self
		
		setClickThrough()
		
//		hotKey.keyDownHandler = {
//			self.toggleTimer()
//		}
	}
	
	func setClickThrough() {
		if let window = NSApplication.shared.windows.first {
			window.ignoresMouseEvents = Settings.main.clickThrough
		}
	}
	
	@objc func toggleClickThrough() {
		Settings.main.clickThrough.toggle()
		clickThroughItem.state = Settings.main.clickThrough ? .on : .off
		setClickThrough()
	}
	
	@objc func toggleMinuteHand() {
		Settings.main.minuteHand.toggle()
		minuteHandItem.state = Settings.main.minuteHand ? .on : .off
	}
	
	@objc func toggleDayMode() {
		Settings.main.dayMode.toggle()
		dayModeItem.state = Settings.main.dayMode ? .on : .off
	}
	
	@objc func toggleTimer() {
		if Settings.main.timer {
			Settings.main.timer = false
			Settings.main.lastTime = Settings.main.timerOffset - Settings.main.time
		} else {
			// this fails for crazy long timers but alternate solutions suck
			Settings.main.timerOffset = Settings.main.time + Settings.main.lastTime - 86400
			Settings.main.timer = true
		}
		timerItem.state = Settings.main.timer ? .on : .off
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
			window.titlebarSeparatorStyle = .none
		}
		
		//Initialising the status bar
		statusBar = StatusBarController.main
		return
	}
}
