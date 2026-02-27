//
//  AbilityProtocolTests.swift
//  
//
//  Created by 黄磊 on 2022/10/29.
//

import XCTest
@testable import AutoConfig
@testable import Ability
@testable import ModuleMonitor

final class AbilityProtocolTests: XCTestCase {
    
    func testAbilityNameEqual() {
        let name1 = AbilityName(NetworkAbility.self)
        let name2 = AbilityName(NetworkAbility.self)
        
        XCTAssertEqual(name1.identifier, name2.identifier)
        XCTAssertEqual(name1.name, name2.name)
        XCTAssertEqual(name1.description, name2.description)
    }
    
    func testAbilityNameNotEqual() {
        let name1 = AbilityName(NetworkAbility.self)
        let name2 = AbilityName(SubNetworkAbility.self)
        
        XCTAssertNotEqual(name1.identifier, name2.identifier)
        XCTAssertNotEqual(name1.name, name2.name)
        XCTAssertNotEqual(name1.description, name2.description)
        
        XCTAssertNotEqual(s_networkAbilityName.identifier, s_localizedAbilityName.identifier)
    }
    
    func testAbilityCheck() {
        let name = AbilityName(NetworkAbility.self)
        
        XCTAssertTrue(name.runCheck(DefaultNetworkAbility()))
        XCTAssertTrue(name.runCheck(OtherNetworkAbility()))
        
        XCTAssertFalse(name.runCheck(DefaultLocalizedAbility()))
    }
    
    func testAutoRegisterAbility() {
        XCTAssertNotNil(AbilityCenter.shared.storage[s_networkAbilityName.identifier] as? NetworkAbility)
        XCTAssertNotNil(AbilityCenter.shared.storage[s_localizedAbilityName.identifier] as? LocalizedAbility)
        XCTAssertEqual((AbilityCenter.shared.storage[s_localizedAbilityName.identifier] as? DefaultLocalizedAbility)?.loadCount, 1)
    }
    
    func testGetAbility() {
        let optionalNetworkAbility = Ability.getAbility(of: s_networkAbilityName)
        let localizedNetworkAbility = Ability.getAbility(of: s_localizedAbilityName)
        let networkAbility = Ability.getAbility(with: DefaultNetworkAbility())
        
        XCTAssertNotNil(optionalNetworkAbility)
        XCTAssertTrue(optionalNetworkAbility === networkAbility)
        XCTAssertTrue(optionalNetworkAbility === Ability.network)
        XCTAssertFalse(optionalNetworkAbility === localizedNetworkAbility)
        XCTAssertTrue(optionalNetworkAbility is DefaultNetworkAbility)
        XCTAssertTrue(networkAbility is DefaultNetworkAbility)
        
        Ability.network.doSomething()
        (Ability.getAbility(of: s_networkAbilityName) as? NetworkAbility)?.doSomething()
    }
    
    func testGetAbilityNotRegister() {
        let notRegisterAbility = DefaultNotRegisterAbility()
        let theNotRegisterAbility = Ability.getAbility(with: notRegisterAbility)
        
        XCTAssertTrue(theNotRegisterAbility === notRegisterAbility)
    }
    
    func testAbilityDuplicateRegister() {
        AbilityMonitor.shared.arrObservers = []
        final class Oberver: AbilityMonitorObserver, @unchecked Sendable {
            var duplicateRegisterGetCall: Bool = false
            func receiveAbilityEvent(_ event: AbilityEvent) {
                if case .duplicateRegisterAbility(_, _)  = event {
                    duplicateRegisterGetCall = true
                }
            }
        }
        let oberver = Oberver()
        let cancellable = AbilityMonitor.shared.addObserver(oberver)
        
        XCTAssertNil(AbilityCenter.shared.storage[s_otherAbilityName.identifier])
        
        AbilityCenter.shared.registerAbilities([.init(DefaultOtherAbility())])
        XCTAssertNotNil(AbilityCenter.shared.storage[s_otherAbilityName.identifier] as? OtherAbility)
        XCTAssertFalse(oberver.duplicateRegisterGetCall)
        
        AbilityCenter.shared.registerAbilities([.init(DefaultOtherAbility())])
        XCTAssertTrue(oberver.duplicateRegisterGetCall)
        
        cancellable.cancel()
    }
    
    func testRegisterAbilityMismatch() {
        AbilityMonitor.shared.arrObservers = []
        final class Oberver: AbilityMonitorObserver, @unchecked Sendable {
            var mismatchGetCall: Bool = false
            func receiveAbilityEvent(_ event: AbilityEvent) {
                if case .registerAbilityMismatch(_)  = event {
                    mismatchGetCall = true
                }
            }
        }
        let oberver = Oberver()
        let cancellable = AbilityMonitor.shared.addObserver(oberver)
        
        XCTAssertFalse(oberver.mismatchGetCall)
        
        AbilityCenter.shared.registerAbilities([.init(DefaultMismatchAbility())])
        XCTAssertTrue(oberver.mismatchGetCall)
        
        cancellable.cancel()
    }
    
    func testRegisterSubAbility() {
        // 先读取单粒，在清空 config 不影响单例
        _ = AbilityCenter.shared
        g_appConfig = [:]
        
        let abilityCenter = AbilityCenter()
        
        let networkAbility = DefaultNetworkAbility()
        let subNetworkAbility = DefaultSubNetworkAbility()
        
        XCTAssertEqual(abilityCenter.storage.count, 0)
        XCTAssertNotEqual(DefaultNetworkAbility.abilityName, DefaultSubNetworkAbility.abilityName)
        
        abilityCenter.registerAbilities([.init(networkAbility), .init(subNetworkAbility)])
        
        XCTAssertEqual(abilityCenter.storage.count, 2)
        let storeNetworkAbility = abilityCenter.storage[DefaultNetworkAbility.abilityName.identifier] as? NetworkAbility
        let storeSubNetworkAbility = abilityCenter.storage[DefaultSubNetworkAbility.abilityName.identifier] as? SubNetworkAbility
        XCTAssertNotNil(storeNetworkAbility)
        XCTAssertNotNil(storeSubNetworkAbility)
        XCTAssertTrue(storeNetworkAbility! === networkAbility)
        XCTAssertTrue(storeSubNetworkAbility! === subNetworkAbility)
        
        abilityCenter.registerAbilities([.init(subNetworkAbility, for: DefaultNetworkAbility.abilityName)])
        XCTAssertEqual(abilityCenter.storage.count, 2)
        let storeNetworkAbility2 = abilityCenter.storage[DefaultNetworkAbility.abilityName.identifier] as? NetworkAbility
        let storeSubNetworkAbility2 = abilityCenter.storage[DefaultSubNetworkAbility.abilityName.identifier] as? SubNetworkAbility
        XCTAssertNotNil(storeNetworkAbility2)
        XCTAssertNotNil(storeSubNetworkAbility2)
        XCTAssertTrue(storeNetworkAbility2! === subNetworkAbility)
        XCTAssertTrue(storeSubNetworkAbility2! === subNetworkAbility)
    }
    
    func testUserDefaultAbility() {
        _ = AbilityCenter.shared
        g_appConfig = [:]
        
        let abilityCenter = AbilityCenter()
        
        XCTAssertEqual(abilityCenter.config.needCheckAbility, true)
        XCTAssertTrue(abilityCenter.config.abilities().isEmpty)
        XCTAssertTrue(abilityCenter.config.funcs().isEmpty)
    }
}

final class OtherNetworkAbility: NetworkAbility {
    func doSomething() {}
}




