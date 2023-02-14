import SwiftUI

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                Rectangle()
                    .fill( .bar )
                    .cornerRadius(10)
                    .shadow(color: Color.gray
                        .opacity(0.2),radius: 1,x: 0,y: 0)
            )
        //.foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeIn(duration: 0.3), value: configuration.isPressed)
    }
}

