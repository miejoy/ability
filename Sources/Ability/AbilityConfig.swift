//
//  AbilityConfig.swift
//  
//
//  Created by 黄磊 on 2022/10/20.
//

import Foundation
import AutoConfig

public extension ConfigKey where Data == AbilityConfig {
    /// 能力配置 key
    static let abilityConfig = ConfigKey<AbilityConfig>()
}

public struct AbilityConfig {
    /// 是否屏蔽 能力自动扫描，默认为 true，即屏蔽自动扫描，设置为 false 可关闭自动扫描，可以节约 半秒钟时间
    let blockAbiliesAutoSearch: Bool
    /// 是否在注册时检查对应能力与能力名称是否匹配，默认为 true
    let needCheckAbility: Bool
    /// 是否在加载完成后禁用方法注册，避免运行过程中的注册方法被替换，默认为 true
    let blockFuncRegisteAfterLoad: Bool
    /// 能力列表
    let abilities: [any AbilityProtocol]
    /// 方法列表
    let funcs: [FuncWrapper]
    /// 能力加载完成回调
    let onLoadCallBack: (() -> Void)?
    
    /// 构造能力配置
    /// - Parameter blockAbiliesAutoSearch: 是否屏蔽 能力自动扫描，默认为 true
    /// - Parameter needCheckAbility: 是否在注册时检查对应能力与能力名称是否匹配，默认为 true
    /// - Parameter blockFuncRegisteAfterLoad: 是否在加载完成后禁用方法注册，避免运行过程中的注册方法被替换，默认为 true
    /// - Parameter abilities: 能力列表
    /// - Parameter onLoadCallBack: 能力加载完成回调
    /// - Returns Self: 返回构造好的能力配置
     public init(
        blockAbiliesAutoSearch: Bool = true,
        needCheckAbility: Bool = true,
        blockFuncRegisteAfterLoad: Bool = true,
        abilities: [any AbilityProtocol] = [],
        funcs: [FuncWrapper] = [],
        onLoadCallBack: (() -> Void)? = nil
    ) {
        self.blockAbiliesAutoSearch = blockAbiliesAutoSearch
        self.needCheckAbility = needCheckAbility
        self.blockFuncRegisteAfterLoad = blockFuncRegisteAfterLoad
        self.abilities = abilities
        self.funcs = funcs
        self.onLoadCallBack = onLoadCallBack
    }
}
