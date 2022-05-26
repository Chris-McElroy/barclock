//
//  Settings.swift
//  barclock
//
//  Created by Chris McElroy on 5/18/22.
//

import Foundation

class Settings: ObservableObject {
	static let main = Settings()
	
	@Published var dayMode = true
	@Published var minuteHand = false
}
