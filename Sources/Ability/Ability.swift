//
//  Ability.swift
//  
//
//  Created by 黄磊 on 2022/10/12.
//

import Foundation
import ModuleMonitor

/// 能力模块
public enum Ability {}

// MARK: - Ability

extension Ability {
    /// 通过能力名称获取能力
    @inlinable
    public static func getAbility(of name: AbilityName) -> (any AbilityProtocol)? {
        AbilityCenter.shared.storage[name.identifier] as? (any AbilityProtocol)
    }
    
    /// 通过默认能力获取能力
    @inlinable
    public static func getAbility<A:AbilityProtocol>(with defaultValue: @autoclosure () -> A) -> (any AbilityProtocol) {
        AbilityCenter.shared.storage[A.abilityName.identifier] as? (any AbilityProtocol) ?? defaultValue()
    }
}

// MARK: - Function

extension Ability {
    // MARK: -FuncKey
    /// 通过方法Key 调用方法
    @inlinable
    public static func execute<Func:FuncKeyProtocol>(
        _ funcKey: Func,
        params: Func.Input
    ) -> Func.Return? {
        guard let block = AbilityCenter.shared.storage[AnyHashable(funcKey)] as? (Func.Input) -> Func.Return else {
            AbilityMonitor.shared.record(event: .funcNotFoundWithKey(funcKey))
            return nil
        }
        return block(params)
    }
    
    /// 调用无返回结果方法
    @inlinable
    public static func execute<Func:FuncKeyProtocol>(
        _ funcKey: Func,
        params: Func.Input
    ) where Func.Return == Void {
        guard let block = AbilityCenter.shared.storage[AnyHashable(funcKey)] as? (Func.Input) -> Func.Return else {
            AbilityMonitor.shared.record(event: .funcNotFoundWithKey(funcKey))
            return
        }
        block(params)
    }
    
    /// 调用无输入参数方法
    @inlinable
    public static func execute<Func:FuncKeyProtocol>(
        _ funcKey: Func
    ) -> Func.Return? where Func.Input == Void {
        guard let block = AbilityCenter.shared.storage[AnyHashable(funcKey)] as? () -> Func.Return else {
            AbilityMonitor.shared.record(event: .funcNotFoundWithKey(funcKey))
            return nil
        }
        return block()
    }
    
    /// 调用无输入参数也无返回参数方法
    @inlinable
    public static func execute<Func:FuncKeyProtocol>(
        _ funcKey: Func
    ) where Func.Input == Void, Func.Return == Void {
        guard let block = AbilityCenter.shared.storage[AnyHashable(funcKey)] as? () -> Func.Return else {
            AbilityMonitor.shared.record(event: .funcNotFoundWithKey(funcKey))
            return
        }
        block()
    }
    
    /// 调用返回值为可选类型的方法
    public static func execute<Func:FuncKeyProtocol>(
        _ funcKey: Func,
        params: Func.Input
    ) -> Func.Return where Func.Return : AnyOptionalType {
        guard let block = AbilityCenter.shared.storage[AnyHashable(funcKey)] as? (Func.Input) -> Func.Return else {
            AbilityMonitor.shared.record(event: .funcNotFoundWithKey(funcKey))
            return Func.Return.nil as! Func.Return
        }
        return block(params)
    }

    /// 调用无输入参数，返回值为可选类型的方法
    public static func execute<Func:FuncKeyProtocol>(
        _ funcKey: Func
    ) -> Func.Return where Func.Input == Void, Func.Return : AnyOptionalType {
        guard let block = AbilityCenter.shared.storage[AnyHashable(funcKey)] as? () -> Func.Return else {
            AbilityMonitor.shared.record(event: .funcNotFoundWithKey(funcKey))
            return Func.Return.nil as! Func.Return
        }
        return block()
    }
    
    // MARK: -DefaultFuncKey
    
    /// 通过方法Key 调用方法
    @inlinable
    public static func execute<Func:DefaultFuncKeyProtocol>(
        _ funcKey: Func,
        params: Func.Input
    ) -> Func.Return {
        let block = (AbilityCenter.shared.storage[AnyHashable(funcKey)] as? (Func.Input) -> Func.Return) ?? funcKey.defaultRun
        return block(params)
    }
    
    /// 调用无返回结果方法
    @inlinable
    public static func execute<Func:DefaultFuncKeyProtocol>(
        _ funcKey: Func,
        params: Func.Input
    ) where Func.Return == Void {
        let block = (AbilityCenter.shared.storage[AnyHashable(funcKey)] as? (Func.Input) -> Func.Return) ?? funcKey.defaultRun
        block(params)
    }
    
    /// 调用无输入参数方法
    @inlinable
    public static func execute<Func:DefaultFuncKeyProtocol>(
        _ funcKey: Func
    ) -> Func.Return? where Func.Input == Void {
        let block = (AbilityCenter.shared.storage[AnyHashable(funcKey)] as? () -> Func.Return) ?? funcKey.defaultRun
        return block()
    }
    
    /// 调用无输入参数也无返回参数方法
    @inlinable
    public static func execute<Func:DefaultFuncKeyProtocol>(
        _ funcKey: Func
    ) where Func.Input == Void, Func.Return == Void {
        let block = (AbilityCenter.shared.storage[AnyHashable(funcKey)] as? () -> Func.Return) ?? funcKey.defaultRun
        block()
    }
    
    /// 调用返回值为可选类型的方法
    public static func execute<Func:DefaultFuncKeyProtocol>(
        _ funcKey: Func,
        params: Func.Input
    ) -> Func.Return where Func.Return : AnyOptionalType {
        let block = (AbilityCenter.shared.storage[AnyHashable(funcKey)] as? (Func.Input) -> Func.Return) ?? funcKey.defaultRun
        return block(params)
    }

    /// 调用无输入参数，返回值为可选类型的方法
    public static func execute<Func:DefaultFuncKeyProtocol>(
        _ funcKey: Func
    ) -> Func.Return where Func.Input == Void, Func.Return : AnyOptionalType {
        let block = (AbilityCenter.shared.storage[AnyHashable(funcKey)] as? () -> Func.Return) ?? funcKey.defaultRun
        return block()
    }
}
