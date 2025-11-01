//
//  SettingsView.swift
//  Exercises
//
//  Created by Artur Spek on 13/10/2025.
//


import SwiftUI

struct SettingsView: View {
    var body: some View {
        
        Link(destination: URL(string: api_url)!) {
            Image(systemName: "link") // SF Symbol for a link
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.blue)
                .padding()
        }
    }
}
