//
//  ArrayExtension.swift
//  ArrayExtension
//
//  Created by apple on 04/10/21.
//

import Foundation
extension Array {
    func createPlaylisfromArray(index:Int) -> [Element] {
        let ArrayCount = self.count
        let splitindex = index
        let leftSplit = self[0 ..< splitindex]
        let rightSplit = self[splitindex ..< ArrayCount]
        let rearrengedArray = rightSplit+leftSplit
        let playlist = Array(rearrengedArray)
        return (playlist)
    }
}
