import SwiftUI
import AudioToolbox

struct SystmeSoundEffectDemo: View {
    // Cycle through a range of common system sound IDs
    private let soundRange = 1...1015
    @State private var currentID: SystemSoundID = 1000

    private func advanceID() {
        if currentID >= soundRange.upperBound {
            currentID = SystemSoundID(soundRange.lowerBound)
        } else {
            currentID += 1
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                // Play current ID
                AudioServicesPlaySystemSound(currentID)
                // Move to the next ID for the next tap
                advanceID()
            }, label: {
                Text("Play Sound (ID: \(currentID))")
                    .foregroundStyle(Color.white)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(.black))
            })

            // Optional: a secondary control to go backwards if you need it
            // Button("Prev") {
            //     if currentID <= soundRange.lowerBound {
            //         currentID = SystemSoundID(soundRange.upperBound)
            //     } else {
            //         currentID -= 1
            //     }
            // }
        }
        .padding()
    }
}

#Preview {
    SystmeSoundEffectDemo()
}
