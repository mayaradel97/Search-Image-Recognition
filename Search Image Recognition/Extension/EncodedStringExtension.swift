//
//  EncodedStringExtension.swift
//  Search Image Recognition
//
//  Created by Mayar Adel 
//

import Foundation
extension String
{
    func encodedURL() -> String
    {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}
