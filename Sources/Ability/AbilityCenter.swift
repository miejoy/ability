//
//  AbilityCenter.swift
//  
//
//  Created by 黄磊 on 2022/10/14.
//

import Foundation
import AutoConfig

public class AbilityCenter {
    public static var shared: AbilityCenter {
        DispatchQueue.syncOnAbilityQueue {
            _shared ?? {
                _shared = .init()
                _shared?.load()
                return _shared!
            }()
        }
    }
    
    /// 内部使用共享实例，受 AbilityQueue 保护
    nonisolated(unsafe) static var _shared: AbilityCenter? = nil
    
    /// 任意储存器，目前外部只提供读取
    private(set) public var storage: [AnyHashable:Any] = [:]
    var config: AbilityConfig
    var usedAbilityNames: Set<AbilityName> = []
    var isLoaded: Bool = false
    
    init() {
        // 读取配置
        self.config = Config.value(for: .abilityConfig, AbilityConfig())
        
        // 注册配置中的能力列表
        registerAbilities(config.abilities())
    }
    
    func load() {
        if isLoaded {
            return
        }
        
        // 调用能力加载方法
        loadAbilities()
        
        // 注册方法列表
        registerFuncs(config.funcs())
        
        // 移除方法
        removeFuncs(config.removeFuncs())
                
        // 调用加载完成方法
        config.onLoadCallBack?()
        
        isLoaded = true
    }
}

// MARK: - Ability
extension AbilityCenter {
    /// 注册能力列表
    func registerAbilities(_ abilities: [AbilityWrapper]) {
        // 先注册
        abilities.forEach { abilityInfo in
            let abilityName = abilityInfo.abilityName
            let ability = abilityInfo.ability
            if config.needCheckAbility {
                guard abilityName.runCheck(ability) else {
                    AbilityMonitor.shared.record(event: .registerAbilityMismatch(ability))
                    return
                }
            }
            if let existAbility = storage[abilityName.identifier] {
                AbilityMonitor.shared.record(event: .duplicateRegisterAbility(existAbility, ability))
            }
            AbilityMonitor.shared.record(event: .registerAbility(ability))
            storage[abilityName.identifier] = ability
            usedAbilityNames.insert(abilityName)
        }
        
    }
    
    // 调用能力加载
    func loadAbilities() {
        usedAbilityNames.forEach { abilityName in
            (storage[abilityName.identifier] as? (any AbilityProtocol))?.load()
        }
    }
}

// MARK: - Function

extension AbilityCenter {
    /// 注册方法列表
    func registerFuncs(_ funcs: [FuncWrapper]) {
        funcs.forEach { funcInfo in
            let key = AnyHashable(funcInfo.funcKey)
            if let existFunc = storage[key] {
                AbilityMonitor.shared.record(event: .duplicateRegisterFunc(funcInfo.funcKey, existFunc, funcInfo.block))
            }
            AbilityMonitor.shared.record(event: .registerFunc(funcInfo.funcKey))
            storage[key] = funcInfo.block
        }
    }
    
    func removeFuncs(_ funcs: [any FuncKeyProtocol]) {
        funcs.forEach { funcKey in
            removeFuncWithKey(funcKey)
        }
    }
    
    /// 注册可运行方法
    public func register<Func: FuncKeyProtocol>(_ funcKey: Func, block: @escaping ((Func.Input)->Func.Return)) {
        DispatchQueue.syncOnAbilityQueue {
            if config.blockFuncRegisterAfterLoad && isLoaded {
                AbilityMonitor.shared.record(event: .blockFuncRegisterAfterLoad(funcKey, block))
                return
            }
            let key = AnyHashable(funcKey)
            if let existFunc = storage[key] {
                AbilityMonitor.shared.record(event: .duplicateRegisterFunc(funcKey, existFunc, block))
            }
            AbilityMonitor.shared.record(event: .registerFunc(funcKey))
            self.storage[key] = block
        }
    }
    
    /// 注册可运行无入参方法
    public func register<Func: FuncKeyProtocol>(_ funcKey: Func, block: @escaping (()->Func.Return)) where Func.Input == Void {
        DispatchQueue.syncOnAbilityQueue {
            if config.blockFuncRegisterAfterLoad && isLoaded {
                AbilityMonitor.shared.record(event: .blockFuncRegisterAfterLoad(funcKey, block))
                return
            }
            let key = AnyHashable(funcKey)
            if let existFunc = storage[key] {
                AbilityMonitor.shared.record(event: .duplicateRegisterFunc(funcKey, existFunc, block))
            }
            AbilityMonitor.shared.record(event: .registerFunc(funcKey))
            self.storage[funcKey] = block
        }
    }
    
    /// 移除注册的对应方法
    public func removeFuncWithKey<Func: FuncKeyProtocol>(_ funcKey: Func) {
        DispatchQueue.syncOnAbilityQueue {
            if config.blockFuncRegisterAfterLoad && isLoaded {
                AbilityMonitor.shared.record(event: .blockFuncRemoveAfterLoad(funcKey))
                return
            }
            let key = AnyHashable(funcKey)
            AbilityMonitor.shared.record(event: .removeFunc(funcKey))
            self.storage.removeValue(forKey: key)
        }
    }
}

// MARK: - Ability Queue

extension DispatchQueue {
    static let abilityQueueDispatchSpecificKey: DispatchSpecificKey<String> = .init()
    /// ability 队列使用的锁
    static let abilityQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "ability.ability_queue")
        queue.setSpecific(key: abilityQueueDispatchSpecificKey, value: queue.label)
        return queue
    }()
    
    /// 在 config 队列中执行
    public static func syncOnAbilityQueue<T>(execute work: () throws -> T) rethrows -> T {
        if DispatchQueue.getSpecific(key: Self.abilityQueueDispatchSpecificKey) == Self.abilityQueue.label {
            return try work()
        }
        return try Self.abilityQueue.sync(execute: work)
    }
}
