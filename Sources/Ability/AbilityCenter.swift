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
        _shared ?? {
            _shared = .init()
            _shared?.load()
            return _shared!
        }()
    }
    
    static var _shared: AbilityCenter? = nil
    
    /// 任意储存器，目前外部只提供读取
    private(set) public var storage: [AnyHashable:Any] = [:]
    var config: AbilityConfig
    var useAbilitiyNames: Set<AbilityName> = []
    var isLoaded: Bool = false
    
    init() {
        // 读取配置
        self.config = Config.value(for: .abilityConfig, AbilityConfig())
        
        // 注册配置中的能力列表
        registeAbilities(config.abilities())
    }
    
    func load() {
        if isLoaded {
            return
        }
        
        // 调用能力加载方法
        loadAbilities()
        
        // 注册方法列表
        registeFuncs(config.funcs())
        
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
    func registeAbilities(_ abilities: [AbilityWrapper]) {
        // 先注册
        abilities.forEach { abilityInfo in
            let abilityName = abilityInfo.abilityName
            let ability = abilityInfo.ability
            if config.needCheckAbility {
                guard abilityName.runCheck(ability) else {
                    AbilityMonitor.shared.record(event: .registeAbilityMismatch(ability))
                    return
                }
            }
            if let existAbility = storage[abilityName.identifier] {
                AbilityMonitor.shared.record(event: .duplicateRegisteAbility(existAbility, ability))
            }
            AbilityMonitor.shared.record(event: .registeAbility(ability))
            storage[abilityName.identifier] = ability
            useAbilitiyNames.insert(abilityName)
        }
        
    }
    
    // 调用能力加载
    func loadAbilities() {
        useAbilitiyNames.forEach { abilityName in
            (storage[abilityName.identifier] as? (any AbilityProtocol))?.load()
        }
    }
}

// MARK: - Function

extension AbilityCenter {
    /// 注册方法列表
    func registeFuncs(_ funcs: [FuncWrapper]) {
        funcs.forEach { funcInfo in
            let key = AnyHashable(funcInfo.funcKey)
            if let existFunc = storage[key] {
                AbilityMonitor.shared.record(event: .duplicateRegisteFunc(funcInfo.funcKey, existFunc, funcInfo.block))
            }
            AbilityMonitor.shared.record(event: .registeFunc(funcInfo.funcKey))
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
        if config.blockFuncRegisteAfterLoad && isLoaded {
            AbilityMonitor.shared.record(event: .blockFuncRegisteAfterLoad(funcKey, block))
            return
        }
        let key = AnyHashable(funcKey)
        if let existFunc = storage[key] {
            AbilityMonitor.shared.record(event: .duplicateRegisteFunc(funcKey, existFunc, block))
        }
        AbilityMonitor.shared.record(event: .registeFunc(funcKey))
        self.storage[key] = block
    }
    
    /// 注册可运行无入参方法
    public func register<Func: FuncKeyProtocol>(_ funcKey: Func, block: @escaping (()->Func.Return)) where Func.Input == Void {
        if config.blockFuncRegisteAfterLoad && isLoaded {
            AbilityMonitor.shared.record(event: .blockFuncRegisteAfterLoad(funcKey, block))
            return
        }
        let key = AnyHashable(funcKey)
        if let existFunc = storage[key] {
            AbilityMonitor.shared.record(event: .duplicateRegisteFunc(funcKey, existFunc, block))
        }
        AbilityMonitor.shared.record(event: .registeFunc(funcKey))
        self.storage[funcKey] = block
    }
    
    /// 移除注册的对应方法
    public func removeFuncWithKey<Func: FuncKeyProtocol>(_ funcKey: Func) {
        if config.blockFuncRegisteAfterLoad && isLoaded {
            AbilityMonitor.shared.record(event: .blockFuncRemoveAfterLoad(funcKey))
            return
        }
        let key = AnyHashable(funcKey)
        AbilityMonitor.shared.record(event: .removeFunc(funcKey))
        self.storage.removeValue(forKey: key)
    }
}
