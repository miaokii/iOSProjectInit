//
//  WeakProxy.swift
//  SwiftLib
//
//  Created by yoctech on 2023/3/3.
//

import UIKit

class WeakProxy: NSObject {

    private weak var target: NSObject?

    static func proxy(target: NSObject) -> WeakProxy {
        let proxy = WeakProxy.init()
        proxy.target = target
        return proxy
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }

    override func responds(to aSelector: Selector!) -> Bool {
        target?.responds(to: aSelector) ?? false
    }

    override func isEqual(_ object: Any?) -> Bool {
        return target?.isEqual(object) ?? false
    }

    override var hash: Int {
        return target?.hash ?? -1
    }

    override var superclass: AnyClass? {
        return target?.superclass ?? nil
    }

    override func isProxy() -> Bool {
        return true
    }

    override func isKind(of aClass: AnyClass) -> Bool {
        return target?.isKind(of: aClass) ?? false
    }

    override func isMember(of aClass: AnyClass) -> Bool {
        return target?.isMember(of: aClass) ?? false
    }

    override func conforms(to aProtocol: Protocol) -> Bool {
        target?.conforms(to: aProtocol) ?? false
    }


    override var description: String {
        target?.description ?? ""
    }

    override var debugDescription: String {
        target?.debugDescription ?? ""
    }
}
