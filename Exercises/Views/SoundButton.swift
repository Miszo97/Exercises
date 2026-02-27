import SwiftUI
import AudioToolbox

struct SystmeSoundEffectDemo: View {
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
                AudioServicesPlaySystemSound(currentID)
                advanceID()
            }, label: {
                Text("Play Sound (ID: \(currentID))")
                    .foregroundStyle(Color.white)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(.black))
            })
        }
        .padding()
    }
}

#Preview {
    SystmeSoundEffectDemo()
}
