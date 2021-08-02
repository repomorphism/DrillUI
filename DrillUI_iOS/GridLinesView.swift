//
//  GridLinesView.swift
//  GridLinesView
//
//  Created by Paul on 8/2/21.
//

import SwiftUI

struct GridLinesView: View {
    let rows: Int
    let columns: Int
    var body: some View {
        Rectangle()
            .fill(.clear)
            .background(GeometryReader { proxy in
                let width = CGFloat(proxy.size.width)
                let height = CGFloat(proxy.size.height)
                let cellWidth = width / CGFloat(columns)
                let cellHeight = height / CGFloat(rows)
                Path { path in
                    for i in 0 ... columns {
                        let x = CGFloat(i) * cellWidth
                        path.move(to: .init(x: x, y: 0))
                        path.addLine(to: .init(x: x, y: height))
                    }
                    for j in 0 ... rows {
                        let y = CGFloat(j) * cellHeight
                        path.move(to: .init(x: 0, y: y))
                        path.addLine(to: .init(x: width, y: y))
                    }
                }
                .stroke(Color.init(white: 1, opacity: 0.05), lineWidth: 1)
            })
    }
}

struct GridLinesView_Previews: PreviewProvider {
    static var previews: some View {
        GridLinesView(rows: 20, columns: 10)
    }
}
