//
//  StoriesViewModel.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/17/23.
//

import Foundation
import UIKit

struct StoriesViewModel {
    let stories: [Story]
}

struct Story {
    let username: String
    let image: UIImage?
}
