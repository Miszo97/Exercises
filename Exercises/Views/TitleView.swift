//
//  TitleView.swift
//  Exercises
//
//  Created by Artur Spek on 13/10/2025.
//


import SwiftUI

struct TitleView: View {
    let api_url = "https://exercises-581797442525.europe-central2.run.app/table"

    var body: some View {
        HStack {
            HeaderView(content: "Exercises")
        }
    }
}
