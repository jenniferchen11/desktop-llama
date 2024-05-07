//
//  AppDelegate.swift
//  llamas
//
//  Created by Jennifer Chen on 5/7/24.
//

import Foundation
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var window2: NSWindow!
    var moveTimer: Timer?
    let randomX = Int.random(in: 5..<6)
    let randomY = Int.random(in: -1..<0)
    var moveDirection: CGPoint!
    var isFlippedHorizontally = false

    var flipViewModel = CompanionViewModel()
    let contentView: ContentView
    var cancellables = Set<AnyCancellable>()

    override init() {
        contentView = ContentView(viewModel: flipViewModel)
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
            styleMask: [.borderless, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.level = .floating
        //make the window transparent
        window.backgroundColor = NSColor.clear
        window.hasShadow = false

        setupIsFrozenSubscriber()
        moveTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(moveWindow), userInfo: nil, repeats: true)
    }
    
    //checks if window should be frozen into place
    private func setupIsFrozenSubscriber() {
        flipViewModel.$isFrozen
            .receive(on: DispatchQueue.main) //ensures updates are on the main thread
            .sink { [weak self] isFrozen in
                self?.handleIsFrozenChanged(isFrozen)
            }
           .store(in: &cancellables)
    }

    private func handleIsFrozenChanged(_ isFrozen: Bool) {
        if isFrozen {
            // stop the window from moving when frozen
            moveTimer?.invalidate()
            moveTimer = nil
        } else {
            // restart moving logic when not frozen
            if moveTimer == nil{
                moveTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(moveWindow), userInfo: nil, repeats: true)
            }
        }
    }

    @objc func moveWindow() {
        let currentOrigin = window.frame.origin
        guard window.screen != nil else { return }
        let windowSize = window.frame.size
        let mouseLocation = NSEvent.mouseLocation

        //calculate moveDirection towards the mouse location
        let newMoveDirectionX = mouseLocation.x - (currentOrigin.x + windowSize.width / 2)
        let newMoveDirectionY = mouseLocation.y - (currentOrigin.y + windowSize.height / 2)

        //normalize moveDirection
        let vectorLength = sqrt(newMoveDirectionX * newMoveDirectionX + newMoveDirectionY * newMoveDirectionY)
        let normalizedMoveDirectionX = newMoveDirectionX / vectorLength
        let normalizedMoveDirectionY = newMoveDirectionY / vectorLength

        //set speed
        let speedFactor: CGFloat = 3.0 // Adjust speed factor to suitable value
        let newOriginX = currentOrigin.x + normalizedMoveDirectionX * speedFactor
        let newOriginY = currentOrigin.y + normalizedMoveDirectionY * speedFactor

        //check if flipping needed, ignore flipping if distance from cursor <= 5
        if normalizedMoveDirectionX <= 0 && vectorLength > 5 && flipViewModel.facingLeft == false {
            flipViewModel.facingLeft = true
        } else if normalizedMoveDirectionX > 0 && vectorLength > 5  && flipViewModel.facingLeft == true {
            flipViewModel.facingLeft = false
        }
        
        //update window position
        if vectorLength > 5 { //move only if there is a non-trivial distance to cover
            window.setFrameOrigin(NSPoint(x: newOriginX, y: newOriginY))
        }
    }
}

class CompanionViewModel: ObservableObject {
    @Published var isFrozen: Bool = false
    @Published var images: [NSImage] = companion.getImages()
    @Published var reversedImages: [NSImage] = flipImages(images: companion.getImages())
    @Published var facingLeft: Bool = false
}
