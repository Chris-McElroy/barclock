//
//  ContentView.swift
//  barclock
//
//  Created by Chris McElroy on 5/18/22.
//

import SwiftUI
import Combine

struct ContentView: View {
	@State var time: Int = 0
	@State var lastTime: Int = 0
	@State var timer: Bool = false
	@State var timerOffset = 0
	@State var update: Bool = false
	@State var tapped: Bool = false
	@ObservedObject var settings = Settings.main
	
    var body: some View {
		VStack(spacing: 0) {
			if timer {
				HStack {
					Spacer()
					Circle()
						.foregroundColor(getColor(time: time - timerOffset, mod: 8, div: 180))
						.onTapGesture {
							if waitForTap() { return }
							if (time - timerOffset)/180 % 8 == 1 {
								timerOffset = time - 86400
							} else {
								timerOffset += 180
							}
						}
					Circle()
						.foregroundColor(getColor(time: time - timerOffset, mod: 6, div: 30))
						.onTapGesture {
							if waitForTap() { return }
//							if (time - timerOffset)/30 % 6 == 0 {
//								timerOffset -= 150
//							} else {
								timerOffset += 30
//							}
						}
					Circle()
						.foregroundColor(getColor(time: time - timerOffset, mod: 6, div: 5))
						.onTapGesture {
							if waitForTap() { return }
//							if (time - timerOffset)/5 % 6 == 0 {
//								timerOffset -= 25
//							} else {
								timerOffset += 5
//							}
						}
					Circle()
						.foregroundColor(getColor(time: time - timerOffset, mod: 5, div: 1))
						.frame(width: settings.minuteHand ? nil : 0)
						.onTapGesture {
							if waitForTap() { return }
//							if (time - timerOffset) % 5 == 0 {
//								timerOffset -= 4
//							} else {
								timerOffset += 1
//							}
						}
					Spacer()
				}
			} else {
				HStack { Circle().opacity(0) }
			}
			Spacer().frame(height: 5)
			HStack {
				Spacer()
				Circle()
					.foregroundColor(getColor(time: time, mod: settings.dayMode ? 8 : 4, div: 180))
					.onTapGesture {
						if waitForTap() { return }
						settings.dayMode.toggle()
						StatusBarController.main.dayModeItem.state = settings.dayMode ? .on : .off
					}
				Circle()
					.foregroundColor(getColor(time: time, mod: 6, div: 30))
					.onTapGesture {
						if waitForTap() { return }
						if timer {
							timer = false
							lastTime = timerOffset - time
						} else {
							// this fails for crazy long timers but alternate solutions suck
							timerOffset = time + lastTime - 86400
							timer = true
						}
					}
				Circle()
					.foregroundColor(getColor(time: time, mod: 6, div: 5))
					.onTapGesture {
						if waitForTap() { return }
						Settings.main.minuteHand.toggle()
						StatusBarController.main.minuteHandItem.state = Settings.main.minuteHand ? .on : .off
					}
				Circle()
					.foregroundColor(getColor(time: time, mod: 5, div: 1))
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
			Color(.displayP3, red: 0.9, green: 0.1, blue: 0.1, opacity: 1.0),
			Color(.displayP3, red: 1.0, green: 1.0, blue: 0.0, opacity: 1.0),
			Color(.displayP3, red: 0.0, green: 1.0, blue: 0.0, opacity: 1.0),
			Color(.displayP3, red: 0.0, green: 1.0, blue: 1.0, opacity: 1.0),
			Color(.displayP3, red: 0.1, green: 0.35, blue: 1.0, opacity: 1.0),
			Color(.displayP3, red: 1.0, green: 0.0, blue: 1.0, opacity: 1.0),
			Color(.displayP3, red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0),
			Color(.displayP3, red: 0.0, green: 0.0, blue: 0.0, opacity: 1.0)
		][(time/div) % mod]
	}
	
	func getTime() {
		let hours = Calendar.current.component(.hour, from: Date())
		let minutes = Calendar.current.component(.minute, from: Date())
		time = minutes + 60*hours
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
