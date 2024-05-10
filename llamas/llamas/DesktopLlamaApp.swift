import SwiftUI
import Combine

let companion: Companion = Companion.LLAMA

@main
struct DesktopLlamaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate //connects the AppDelegate to SwiftUI
    var body: some Scene {
        WindowGroup {
            ControlView(viewModel: appDelegate.controlViewModel)
        }
    }
}
