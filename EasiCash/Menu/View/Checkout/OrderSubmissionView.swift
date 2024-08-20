//
//  OrderSubmissionView.swift
//  EasiCash
//
//  Created by CHENGTAO on 8/17/24.
//

import SwiftUI

struct OrderSubmissionView: View {

    @Binding var submissionTapped: Bool

    @State private var isAnimating: Bool = false
    @State private var second: Int = 0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue, lineWidth: 4)
                .gradientForeground(colors: [Color.purple, Color.cyan, Color.pink])

            VStack(alignment: .center) {
                HStack {
                    Circle()
                        .frame(width: 80)
                        .gradientForeground(colors: [Color.purple, Color.cyan, Color.pink])
                        .overlay {
                            Image(systemName: "checkmark")
                                .fontWeight(.bold)
                                .font(.system(size: 40))
                                .gradientForeground(colors: [Color.green, Color.mint])
                                .blur(radius: isAnimating ? 0 : 3.0)
                                .scaleEffect(isAnimating ? 1 : 0.25)
                                .opacity(isAnimating ? 1 : 0)
                        }
                }

                Text("Your order has been submitted!")
                    .font(.system(size: 18).bold())
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: 150, maxHeight: 150)
        .padding()
        .onAppear {
            withAnimation(.linear(duration: 0.5)) {
                isAnimating.toggle()
            }
        }
        .onTapGesture {
            submissionTapped.toggle()
        }
        .onReceive(timer) { _ in
            if second == 2 {
                submissionTapped.toggle()
                timer.upstream.connect().cancel()
            }
            second += 1
        }
    }
}

#Preview {
    OrderSubmissionView(submissionTapped: .constant(false))
}
