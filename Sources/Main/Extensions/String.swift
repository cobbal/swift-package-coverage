//
//  String.swift
//  swift-package-coverage
//
//  Created by Braden Scothern on 5/26/21.
//  Copyright © 2021 Braden Scothern. All rights reserved.
//

extension String {
    func uppercasedFirst() -> String {
        guard let first = self.first else {
            return ""
        }
        return "\(first.uppercased())\(dropFirst())"
    }
}
