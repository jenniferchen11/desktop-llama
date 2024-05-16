import SwiftUI
import Combine

@main
struct DesktopLlamaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ControlView(viewModel: appDelegate.controlViewModel)
        }
    }
}
