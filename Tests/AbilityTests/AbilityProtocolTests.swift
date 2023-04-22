//
//  AbilityProtocolTests.swift
//  
//
//  Created by 黄磊 on 2022/10/29.
//

import XCTest
@testable import AutoConfig
@testable import Ability

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
    
    func testGetAbilityNotRegiste() {
        let notRegisteAbility = DefaultNotRegisteAbility()
        let theNotRegisteAbility = Ability.getAbility(with: notRegisteAbility)
        
        XCTAssertTrue(theNotRegisteAbility === notRegisteAbility)
    }
    
    func testAbilityDuplicateRegiste() {
        AbilityMonitor.shared.arrObservers = []
        class Oberver: AbilityMonitorOberver {
            var duplicateRegisterGetCall: Bool = false
            func receiveAbilityEvent(_ event: AbilityEvent) {
                if case .duplicateRegisteAbility(_, _)  = event {
                    duplicateRegisterGetCall = true
                }
            }
        }
        let oberver = Oberver()
        let cancellable = AbilityMonitor.shared.addObserver(oberver)
        
        XCTAssertNil(AbilityCenter.shared.storage[s_otherAbilityName.identifier])
        
        AbilityCenter.shared.registeAbilities([.init(DefaultOtherAbility())])
        XCTAssertNotNil(AbilityCenter.shared.storage[s_otherAbilityName.identifier] as? OtherAbility)
        XCTAssertFalse(oberver.duplicateRegisterGetCall)
        
        AbilityCenter.shared.registeAbilities([.init(DefaultOtherAbility())])
        XCTAssertTrue(oberver.duplicateRegisterGetCall)
        
        cancellable.cancel()
    }
    
    func testRegisteAbilityMismatch() {
        AbilityMonitor.shared.arrObservers = []
        class Oberver: AbilityMonitorOberver {
            var mismatchGetCall: Bool = false
            func receiveAbilityEvent(_ event: AbilityEvent) {
                if case .registeAbilityMismatch(_)  = event {
                    mismatchGetCall = true
                }
            }
        }
        let oberver = Oberver()
        let cancellable = AbilityMonitor.shared.addObserver(oberver)
        
        XCTAssertFalse(oberver.mismatchGetCall)
        
        AbilityCenter.shared.registeAbilities([.init(DefaultMismatchAbility())])
        XCTAssertTrue(oberver.mismatchGetCall)
        
        cancellable.cancel()
    }
    
    func testRegisteSubAbility() {
        // 先读取单粒，在清空 config 不影响单例
        _ = AbilityCenter.shared
        g_appConfig = [:]
        
        let abilityCenter = AbilityCenter()
        
        let networkAbility = DefaultNetworkAbility()
        let subNetworkAbility = DefaultSubNetworkAbility()
        
        XCTAssertEqual(abilityCenter.storage.count, 0)
        XCTAssertNotEqual(DefaultNetworkAbility.abilityName, DefaultSubNetworkAbility.abilityName)
        
        abilityCenter.registeAbilities([.init(networkAbility), .init(subNetworkAbility)])
        
        XCTAssertEqual(abilityCenter.storage.count, 2)
        let storeNetworkAbility = abilityCenter.storage[DefaultNetworkAbility.abilityName.identifier] as? NetworkAbility
        let storeSubNetworkAbility = abilityCenter.storage[DefaultSubNetworkAbility.abilityName.identifier] as? SubNetworkAbility
        XCTAssertNotNil(storeNetworkAbility)
        XCTAssertNotNil(storeSubNetworkAbility)
        XCTAssertTrue(storeNetworkAbility! === networkAbility)
        XCTAssertTrue(storeSubNetworkAbility! === subNetworkAbility)
        
        abilityCenter.registeAbilities([.init(subNetworkAbility, for: DefaultNetworkAbility.abilityName)])
        XCTAssertEqual(abilityCenter.storage.count, 2)
        let storeNetworkAbility2 = abilityCenter.storage[DefaultNetworkAbility.abilityName.identifier] as? NetworkAbility
        let storeSubNetworkAbility2 = abilityCenter.storage[DefaultSubNetworkAbility.abilityName.identifier] as? SubNetworkAbility
        XCTAssertNotNil(storeNetworkAbility2)
        XCTAssertNotNil(storeSubNetworkAbility2)
        XCTAssertTrue(storeNetworkAbility2! === subNetworkAbility)
        XCTAssertTrue(storeSubNetworkAbility2! === subNetworkAbility)
    }
    
    func testUserDefaultAbilit() {
        _ = AbilityCenter.shared
        g_appConfig = [:]
        
        let abilityCenter = AbilityCenter()
        
        XCTAssertEqual(abilityCenter.config.blockAbiliesAutoSearch, true)
        XCTAssertEqual(abilityCenter.config.needCheckAbility, true)
        XCTAssertTrue(abilityCenter.config.abilities().isEmpty)
        XCTAssertTrue(abilityCenter.config.funcs().isEmpty)
    }
}

class OtherNetworkAbility: NetworkAbility {
    func doSomething() {}
}




