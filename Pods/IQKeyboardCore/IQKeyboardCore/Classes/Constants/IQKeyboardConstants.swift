//
<<<<<<<< HEAD:Pods/Kingfisher/Sources/Utility/Runtime.swift
//  Runtime.swift
//  Kingfisher
//
//  Created by Wei Wang on 2018/10/12.
//
//  Copyright (c) 2019 Wei Wang <onevcat@gmail.com>
========
//  IQKeyboardConstants.swift
//  https://github.com/hackiftekhar/IQKeyboardCore
//  Copyright (c) 2013-24 Iftekhar Qurashi.
>>>>>>>> ede0891d7937aff1066126b682ba54f3a353cd13:Pods/IQKeyboardCore/IQKeyboardCore/Classes/Constants/IQKeyboardConstants.swift
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

<<<<<<<< HEAD:Pods/Kingfisher/Sources/Utility/Runtime.swift
func getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
    if #available(iOS 14, macOS 11, watchOS 7, tvOS 14, *) { // swift 5.3 fixed this issue (https://github.com/swiftlang/swift/issues/46456)
        return objc_getAssociatedObject(object, key) as? T
    } else {
        return objc_getAssociatedObject(object, key) as AnyObject as? T
    }
========
/**
 `IQEnableModeDefault`
 Pick default settings.
 
 `IQEnableModeEnabled`
 setting is enabled.
 
 `IQEnableModeDisabled`
 setting is disabled.
 */
@available(iOSApplicationExtension, unavailable)
@objc public enum IQEnableMode: Int {
    case `default`
    case enabled
    case disabled
>>>>>>>> ede0891d7937aff1066126b682ba54f3a353cd13:Pods/IQKeyboardCore/IQKeyboardCore/Classes/Constants/IQKeyboardConstants.swift
}

func setRetainedAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer, _ value: T) {
    objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}
