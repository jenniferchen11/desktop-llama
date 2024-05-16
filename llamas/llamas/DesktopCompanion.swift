//
//  DesktopCompanion.swift
//  llamas
//
//  Created by Jennifer Chen on 5/16/24.
//

import Foundation
import SwiftUI

// Define your own desktop companion by adding it to the Companion enum!
enum DesktopCompanion {
    case CINAMOROLL
    case LLAMA
    
    //returns images that comprise the GIF animation of the companion as it moves on the screen
    func getMovingImages() -> [NSImage] {
        switch self {
        case .CINAMOROLL:
            return getCinamorollImages()
        case .LLAMA:
            return getPartyLlamaImages()
        }
    }
    
    //returns images that comprise the GIF animation of the companion when it is "asleep"
    func getSleepingImages() -> [NSImage] {
        switch self {
            case .CINAMOROLL:
                return getCinamorollImages()
            case .LLAMA:
                return getSleepingLlamaImages()
        }
    }
}

class CompanionViewModel: ObservableObject {
    @Published var isFrozen: Bool = false
    @Published var images: [NSImage] = COMPANION.getMovingImages()
    @Published var reversedImages: [NSImage] = flipImages(images: COMPANION.getMovingImages())
    @Published var inPlaceImages: [NSImage] = COMPANION.getSleepingImages()
    @Published var facingLeft: Bool = false
}
