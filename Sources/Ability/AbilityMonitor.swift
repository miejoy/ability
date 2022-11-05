//
//  AbilityMonitor.swift
//  
//
//  Created by 黄磊 on 2022/10/28.
//

import Foundation
import Combine

/// 能力事件
public enum AbilityEvent {
    case registeAbility(any AbilityProtocol)
    case registeFunc(any FuncKeyProtocol)
    case removeFunc(any FuncKeyProtocol)
    case registeAbilityMismatch(any AbilityProtocol)
    case blockFuncRegisteAfterLoad(_ funcKey: any FuncKeyProtocol, _ func: Any)
    case blockFuncRemoveAfterLoad(_ funcKey: any FuncKeyProtocol)
    case duplicateRegisteAbility(_ old: Any, _ new: Any)
    case duplicateRegisteFunc(_ funcKey: any FuncKeyProtocol, _ old: Any, _ new: Any)
    case funcNotFoundWithKey(any FuncKeyProtocol)
//    case fatalError(String)
}

public protocol AbilityMonitorOberver: AnyObject {
    func receiveAbilityEvent(_ event: AbilityEvent)
}

/// 能力监听器
public final class AbilityMonitor {
        
    struct Observer {
        let observerId: Int
        weak var observer: AbilityMonitorOberver?
    }
    
    /// 监听器共享单例
    public static var shared: AbilityMonitor = .init()
    
    /// 所有观察者
    var arrObservers: [Observer] = []
    var generateObserverId: Int = 0
    
    required init() {
    }
    
    /// 添加观察者
    public func addObserver(_ observer: AbilityMonitorOberver) -> AnyCancellable {
        generateObserverId += 1
        let observerId = generateObserverId
        arrObservers.append(.init(observerId: generateObserverId, observer: observer))
        return AnyCancellable { [weak self] in
            if let index = self?.arrObservers.firstIndex(where: { $0.observerId == observerId}) {
                self?.arrObservers.remove(at: index)
            }
        }
    }
    
    /// 记录对应事件，这里只负责将所有事件传递给观察者
    @usableFromInline
    func record(event: AbilityEvent) {
        guard !arrObservers.isEmpty else { return }
        arrObservers.forEach { $0.observer?.receiveAbilityEvent(event) }
    }
}

