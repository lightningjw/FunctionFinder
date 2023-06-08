//
//  Extensions.swift
//  FunctionFinder
//
//  Created by Justin Wong on 5/26/23.
//

import Foundation
import UIKit

extension UIView{
    
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    
    public var top: CGFloat {
        return frame.origin.y
    }
    
    public var bottom: CGFloat {
        return frame.origin.y + frame.size.height
    }
    
    public var left: CGFloat {
        return frame.origin.x
    }
    
    public var right: CGFloat {
        return frame.origin.x + frame.size.width
    }
}

extension Decodable {
    init?(with dictionary: [String: Any]) {
        guard let data = try? JSONSerialization.data(
            withJSONObject: dictionary,
            options: .prettyPrinted
        )
        else {
            return nil
        }
        guard let result = try? JSONDecoder().decode(
            Self.self,
            from: data
        )
        else {
            return nil
        }
        self = result
    }
}

extension Encodable {
    func asDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        let json = try? JSONSerialization.jsonObject(
            with: data,
            options: .allowFragments
        ) as? [String: Any]
        return json
    }
}

extension String {
    func safeDatabaseKey() -> String {
        return self.replacingOccurrences(of: "@", with: "-").replacingOccurrences(of: ".", with: "-")
    }
}

extension DateFormatter {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

extension String {
    static func date(from date: Date) -> String? {
        let formatter = DateFormatter.formatter
        let string = formatter.string(from: date)
        return string
    }
}
