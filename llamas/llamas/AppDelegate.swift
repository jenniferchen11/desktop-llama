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
    var moveDirection = CGPoint(x: 1, y: 1)

    var companionViewModel = CompanionViewModel()
    var controlViewModel = ControlViewModel()
    let contentView: ContentView
    var cancellables = Set<AnyCancellable>()

    override init() {
        contentView = ContentView(viewModel: companionViewModel)
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupIsFrozenSubscriber()
        setupFollowCursorSubscriber()
        createAnimationWindow()
    }
    
    private func createAnimationWindow(){
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
    }
    
    private func setupTimer(behaviour: String){
        moveTimer?.invalidate()
        moveTimer = nil
        if behaviour == "followCursor"{
            moveTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(moveByFollowCursor), userInfo: nil, repeats: true)
        }
        else if behaviour == "random"{
            moveTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(moveByRandom), userInfo: nil, repeats: true)
        }
        else{
            return
        }
    }
    
    private func setupFollowCursorSubscriber() {
        controlViewModel.$followCursor
            .receive(on: DispatchQueue.main)
            .sink { [weak self] followCursor in
                self?.handleFollowCursorChanged(followCursor)
            }
            .store(in: &cancellables)
    }
    
    private func handleFollowCursorChanged(_ followCursor: Bool) {
        if followCursor {
            setupTimer(behaviour: "followCursor")
        } else {
            setupTimer(behaviour: "random")
        }
    }
    
    //checks if window should be frozen into place
    private func setupIsFrozenSubscriber() {
        companionViewModel.$isFrozen
            .receive(on: DispatchQueue.main) //ensures updates are on the main thread
            .sink { [weak self] isFrozen in
                self?.handleIsFrozenChanged(isFrozen)
            }
           .store(in: &cancellables)
    }

    private func handleIsFrozenChanged(_ isFrozen: Bool) {
        if isFrozen {
            // stop the window from moving when frozen
            setupTimer(behaviour: "")
        } else {
            // restart moving logic when not frozen
            if moveTimer == nil{
                if controlViewModel.followCursor {
                    setupTimer(behaviour: "followCursor")
                } else {
                    setupTimer(behaviour: "random")
                }
            }
        }
    }

    @objc func moveByFollowCursor() {
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
        if normalizedMoveDirectionX <= 0 && vectorLength > 5 && companionViewModel.facingLeft == false {
            companionViewModel.facingLeft = true
        } else if normalizedMoveDirectionX > 0 && vectorLength > 5  && companionViewModel.facingLeft == true {
            companionViewModel.facingLeft = false
        }
        
        //update window position
        if vectorLength > 5 { //move only if there is a non-trivial distance to cover
            window.setFrameOrigin(NSPoint(x: newOriginX, y: newOriginY))
        }
    }
    
    @objc func moveByRandom() {
        let currentOrigin = window.frame.origin
        guard let screen = window.screen else { return } // ensure there is a screen
        let windowSize = window.frame.size

        // Calculate new origin
        var newOriginX = currentOrigin.x + moveDirection.x * 1 // adjust speed by multiplying
        var newOriginY = currentOrigin.y + moveDirection.y * 1

        // Check boundaries and adjust direction if necessary
        let maxOriginX = screen.visibleFrame.maxX - windowSize.width
        let maxOriginY = screen.visibleFrame.maxY - windowSize.height

        // Reverse direction if hitting edges
        if newOriginX <= screen.visibleFrame.minX || newOriginX >= maxOriginX {
            moveDirection.x = -moveDirection.x
            newOriginX = currentOrigin.x + moveDirection.x * 5
        }
        if newOriginY <= screen.visibleFrame.minY || newOriginY >= maxOriginY {
            moveDirection.y = -moveDirection.y
            newOriginY = currentOrigin.y + moveDirection.y * 5
        }
        
        //check if flipping needed, ignore flipping if distance from cursor <= 5
        if moveDirection.x < 0 && companionViewModel.facingLeft == false {
            companionViewModel.facingLeft = true
        } else if moveDirection.x > 0  && companionViewModel.facingLeft == true {
            companionViewModel.facingLeft = false
        }

        // Update window position
        window.setFrameOrigin(NSPoint(x: newOriginX, y: newOriginY))
    }

}

class CompanionViewModel: ObservableObject {
    @Published var isFrozen: Bool = false
    @Published var images: [NSImage] = companion.getImages()
    @Published var reversedImages: [NSImage] = flipImages(images: companion.getImages())
    @Published var inPlaceImages: [NSImage] = getSleepingLlamaImages() 
    @Published var facingLeft: Bool = false
}
