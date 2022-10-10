//
//  ContentView.swift
//  barclock
//
//  Created by Chris McElroy on 5/18/22.
//

import SwiftUI
import Combine

struct ContentView: View {
	@State var update: Bool = false
	@State var tapped: Bool = false
	@ObservedObject var settings = Settings.main
	
    var body: some View {
		VStack(spacing: 0) {
			if settings.timer {
				HStack {
					Spacer()
					Circle()
						.foregroundColor(getColor(time: settings.time - settings.timerOffset, mod: 8, div: 180))
						.onTapGesture {
							if waitForTap() { return }
							if (settings.time - settings.timerOffset)/180 % 8 == 0 && (settings.timerOffset - settings.time) % 180 != 0 {
								settings.timerOffset = settings.time - 86400
							} else {
								settings.timerOffset += 180
							}
						}
					Circle()
						.foregroundColor(getColor(time: settings.time - settings.timerOffset, mod: 6, div: 30))
						.onTapGesture {
							if waitForTap() { return }
//							if (time - timerOffset)/30 % 6 == 0 {
//								timerOffset -= 150
//							} else {
							settings.timerOffset += 30
//							}
						}
					Circle()
						.foregroundColor(getColor(time: settings.time - settings.timerOffset, mod: 5, div: 6))
						.onTapGesture {
							if waitForTap() { return }
//							if (time - timerOffset)/5 % 6 == 0 {
//								timerOffset -= 25
//							} else {
							settings.timerOffset += 6
//							}
						}
					Circle()
						.foregroundColor(getColor(time: settings.time - settings.timerOffset, mod: 6, div: 1))
						.frame(width: settings.minuteHand ? nil : 0)
						.onTapGesture {
							if waitForTap() { return }
//							if (time - timerOffset) % 5 == 0 {
//								timerOffset -= 4
//							} else {
							settings.timerOffset += 1
//							}
						}
					Spacer()
				}
			} else {
				HStack {
					Spacer()
					Circle()
						.foregroundColor(.clear)
					Circle()
						.foregroundColor(.clear)
					Circle()
						.foregroundColor(.clear)
					Circle()
						.foregroundColor(.clear)
						.frame(width: settings.minuteHand ? nil : 0)
					Spacer()
				}
			}
			Spacer().frame(height: 5)
			HStack {
				Spacer()
				Circle()
					.foregroundColor(getColor(time: settings.time, mod: settings.dayMode ? 8 : 4, div: 180))
					.onTapGesture {
						if waitForTap() { return }
						settings.dayMode.toggle()
						StatusBarController.main.dayModeItem.state = settings.dayMode ? .on : .off
					}
				Circle()
					.foregroundColor(getColor(time: settings.time, mod: 6, div: 30))
					.onTapGesture {
						if waitForTap() { return }
						if settings.timer {
							settings.timer = false
							settings.lastTime = settings.timerOffset - settings.time
						} else {
							// this fails for crazy long timers but alternate solutions suck
							settings.timerOffset = settings.time + settings.lastTime - 86400
							settings.timer = true
						}
					}
				Circle()
					.foregroundColor(getColor(time: settings.time, mod: 5, div: 6))
					.onTapGesture {
						if waitForTap() { return }
						Settings.main.minuteHand.toggle()
						StatusBarController.main.minuteHandItem.state = Settings.main.minuteHand ? .on : .off
					}
				Circle()
					.foregroundColor(getColor(time: settings.time, mod: 6, div: 1))
					.frame(width: settings.minuteHand ? nil : 0)
				Spacer()
			}
			.frame(minHeight: 3)
		}
		.onAppear {
			getTime()
			Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
				getTime()
			})
		}
    }
	
	func getColor(time: Int, mod: Int, div: Int) -> Color {
		[
			Color(.displayP3, red: 0.6, green: 0.0, blue: 0.0, opacity: 1.0),
			Color(.displayP3, red: 1.0, green: 1.0, blue: 0.0, opacity: 1.0),
			Color(.displayP3, red: 0.0, green: 0.6, blue: 0.0, opacity: 1.0),
			Color(.displayP3, red: 0.0, green: 1.0, blue: 0.85, opacity: 1.0),
			Color(.displayP3, red: 0.0, green: 0.0, blue: 1.0, opacity: 1.0),
			Color(.displayP3, red: 0.9, green: 0.0, blue: 1.0, opacity: 1.0),
			Color(.displayP3, red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0),
			Color(.displayP3, red: 0.0, green: 0.0, blue: 0.0, opacity: 1.0)
		][(time/div) % mod]
	}
	
	func getTime() {
		let hours = Calendar.current.component(.minute, from: Date())
		let minutes = Calendar.current.component(.second, from: Date())
		settings.time = minutes + 60*hours
	}
	
	func waitForTap() -> Bool {
		// prevents weird double tap glitch i was getting
		
		if tapped { print("stopped"); return true }
		
		tapped = true
		
		Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
			tapped = false
		})
		
		return false
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
