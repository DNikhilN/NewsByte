//
//  AppConsole.swift

import Foundation

final class AppConsole {
    class func printLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
            print(items,separator: separator,terminator: terminator)
        #endif
    }
}
