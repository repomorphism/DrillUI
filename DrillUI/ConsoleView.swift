//
//  ConsoleView.swift
//  DrillUI
//
//  Created by Paul on 7/27/21.
//

import SwiftUI


struct ConsoleOutput: Identifiable {
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
                            .onAppear {
                                if outputs.last?.id == output.id {
                                    withAnimation {
                                        scrollView.scrollTo(output.id, anchor: .top)
                                    }
                                }
                            }
                            .padding(.bottom, 8)
                    }
                }
                .padding(EdgeInsets(top: 20, leading: 2, bottom: 20, trailing: 16))
            }
            .font(.system(.body, design: .monospaced))
            .background(Color(NSColor(named: "ConsoleBackgroundColor")!))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleView(outputs: .constant([ConsoleOutput("Hello world")]))
    }
}
