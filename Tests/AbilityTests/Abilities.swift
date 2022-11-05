//
//  NetworkAbility.swift
//  
//
//  Created by 黄磊 on 2022/10/12.
//

@testable import Ability

let s_networkAbilityName = AbilityName(NetworkAbility.self)
let s_localizedAbilityName = AbilityName(LocalizedAbility.self)
let s_otherAbilityName = AbilityName(OtherAbility.self)
let s_notRegisteAbilityName = AbilityName(NotRegisteAbility.self)

protocol NetworkAbility: AbilityProtocol {
    func doSomething()
}
extension NetworkAbility {
    static var abilityName: AbilityName { s_networkAbilityName }
}

extension Ability {
    static var network : NetworkAbility = {
        Ability.getAbility(with: DefaultNetworkAbility()) as! NetworkAbility
    }()
}

class DefaultNetworkAbility: NetworkAbility {
    func doSomething() {}
}

protocol SubNetworkAbility: NetworkAbility {}


protocol LocalizedAbility: AbilityProtocol {}
extension LocalizedAbility {
    static var abilityName: AbilityName { s_localizedAbilityName }
}
class DefaultLocalizedAbility: LocalizedAbility {
    var loadCount: Int = 0
    func load() {
        loadCount += 1
    }
}

protocol OtherAbility: AbilityProtocol {}
extension OtherAbility {
    static var abilityName: AbilityName { s_otherAbilityName }
}
class DefaultOtherAbility: OtherAbility {
}

protocol NotRegisteAbility: AbilityProtocol {}
extension NotRegisteAbility {
    static var abilityName: AbilityName { s_notRegisteAbilityName }
}
class DefaultNotRegisteAbility: NotRegisteAbility {
}

protocol MismatchAbility: AbilityProtocol {}
extension MismatchAbility {
    static var abilityName: AbilityName { s_notRegisteAbilityName }
}
class DefaultMismatchAbility: MismatchAbility {
}
