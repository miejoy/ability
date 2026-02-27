//
//  AbilityMonitor.swift
//  
//
//  Created by 黄磊 on 2022/10/28.
//

import Foundation
import Combine
import ModuleMonitor

/// 能力事件
public enum AbilityEvent: MonitorEvent, @unchecked Sendable {
    case registerAbility(AbilityProtocol)
    case registerFunc(any FuncKeyProtocol)
    case removeFunc(any FuncKeyProtocol)
    case registerAbilityMismatch(AbilityProtocol)
    case blockFuncRegisterAfterLoad(_ funcKey: any FuncKeyProtocol, _ func: Any)
    case blockFuncRemoveAfterLoad(_ funcKey: any FuncKeyProtocol)
    case duplicateRegisterAbility(_ old: Any, _ new: Any)
    case duplicateRegisterFunc(_ funcKey: any FuncKeyProtocol, _ old: Any, _ new: Any)
    case funcNotFoundWithKey(any FuncKeyProtocol)
    case fatalError(String)
}

public protocol AbilityMonitorObserver: MonitorObserver {
    func receiveAbilityEvent(_ event: AbilityEvent)
}

/// 能力监听器
public final class AbilityMonitor: ModuleMonitor<AbilityEvent>, @unchecked Sendable {
    public static let shared: AbilityMonitor = {
        AbilityMonitor { event, observer in
            (observer as? AbilityMonitorObserver)?.receiveAbilityEvent(event)
        }
    }()

    public func addObserver(_ observer: AbilityMonitorObserver) -> AnyCancellable {
        super.addObserver(observer)
    }
    
    public override func addObserver(_ observer: MonitorObserver) -> AnyCancellable {
        Swift.fatalError("Only AbilityMonitorObserver can observe this monitor")
    }
}

