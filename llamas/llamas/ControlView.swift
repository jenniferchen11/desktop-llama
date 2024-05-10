//
//  ControlView.swift
//  llamas
//
//  Created by Jennifer Chen on 5/8/24.
//

import Foundation
import SwiftUI

struct ControlView: View {
    @ObservedObject var viewModel: ControlViewModel

    var body: some View {
        Toggle("Follow Cursor", isOn: $viewModel.followCursor)
            .padding()
    }
}

class ControlViewModel: ObservableObject {
    @Published var followCursor: Bool = false
}
