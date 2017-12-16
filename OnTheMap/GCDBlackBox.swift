//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Joshua Schindler on 10/9/17.
//  Copyright © 2017 Joshua Schindler. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
