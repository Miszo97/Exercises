//
//  ConvertSecondsToMinutes.swift
//  Exercises
//
//  Created by Artur Spek on 13/11/2025.
//

import Foundation


func formatSecondsToMinutes(seconds: Int) -> String {
    let minutes = seconds / 60
    let seconds_reminder = seconds % 60
    
    if (minutes != 0 && seconds_reminder > 0)
    {
        return "\(minutes) min \(seconds_reminder) sec"
    }
    
    if minutes != 0 { return "\(minutes) min"}
    
    return "\(seconds_reminder) sec"
}

