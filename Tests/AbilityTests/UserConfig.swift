//
//  File.swift
//  
//
//  Created by 黄磊 on 2022/10/29.
//

import AutoConfig
@testable import Ability

class UserConfig: ConfigProtocol {

    static var configs: Set<ConfigPair> = [
        .init(.abilityConfig, abilityConfig)
    ]
}

let abilityConfig: AbilityConfig = {
    .init(
        blockFuncRegisteAfterLoad: false,
        abilities: [
            DefaultNetworkAbility(),
            DefaultLocalizedAbility()
        ],
        funcs: [
            .init(funcStringToInt, Funcs.stringToInt),
            .init(funcStringToVoid, Funcs.stringToVoid),
            .init(funcVoidToInt, Funcs.voidToInt),
            .init(funcVoidToVoid, Funcs.voidToVoid),
            .init(funcStringToOptionalInt, Funcs.stringToOptionalInt),
            .init(funcVoidToOptionalInt, Funcs.voidToOptionalInt),
            .init(funcVoidToOptionalInt, Funcs.voidToOptionalInt),
            .init(otherFuncStringToInt, Funcs.stringToInt)
        ],
        removeFuncs: [
            otherFuncStringToInt
        ]
    )
}()
