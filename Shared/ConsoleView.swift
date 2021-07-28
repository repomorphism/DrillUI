//
//  ConsoleView.swift
//  DrillUI
//
//  Created by Paul on 7/27/21.
//

import SwiftUI
import Combine


struct ConsoleOutput: Identifiable, Equatable {
    let id: UUID = .init()
    let content: String

    init(_ content: String) {
        self.content = content
    }
}


struct ConsoleView: View {

    @Binding var outputs: [ConsoleOutput]

    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(outputs) { output in
                        Text(output.content)
                            .padding(.bottom, 8)
                    }
                    Spacer()
                        .frame(height: 10)
                        .id("bottomSpacer")
                }
                .padding(EdgeInsets(top: 20, leading: 2, bottom: 20, trailing: 16))
            }
            .onChange(of: outputs) { val in
                scrollView.scrollTo("bottomSpacer")
            }
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.init(white: 0.95))
            .background(Color("ConsoleBackgroundColor"))
        }
    }
}

