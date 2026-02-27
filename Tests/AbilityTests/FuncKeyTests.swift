//
//  FunctionKeyTests.swift
//  
//
//  Created by 黄磊 on 2022/10/31.
//

import XCTest
@testable import Ability
@testable import AutoConfig
@testable import ModuleMonitor

final class FunctionKeyTests: XCTestCase {
    func testAutoRegisterFuncs() {
        XCTAssertNotNil(AbilityCenter.shared.storage[AnyHashable(funcStringToInt)] as? (String) -> Int)
        XCTAssertNotNil(AbilityCenter.shared.storage[AnyHashable(funcStringToVoid)] as? (String) -> Void)
        XCTAssertNotNil(AbilityCenter.shared.storage[AnyHashable(funcVoidToInt)] as? () -> Int)
        XCTAssertNotNil(AbilityCenter.shared.storage[AnyHashable(funcVoidToVoid)] as? () -> Void)
        XCTAssertNotNil(AbilityCenter.shared.storage[AnyHashable(funcStringToOptionalInt)] as? (String) -> Int?)
        XCTAssertNotNil(AbilityCenter.shared.storage[AnyHashable(funcVoidToOptionalInt)] as? () -> Int?)
        XCTAssertNil(AbilityCenter.shared.storage[AnyHashable(otherFuncStringToInt)])
    }
    
    func testRegisterFuncs() {
        if (AbilityCenter.shared.storage[AnyHashable(otherFuncStringToInt)] != nil) {
            AbilityCenter.shared.removeFuncWithKey(otherFuncStringToInt)
        }
        if (AbilityCenter.shared.storage[AnyHashable(otherFuncVoidToInt)] != nil) {
            AbilityCenter.shared.removeFuncWithKey(otherFuncVoidToInt)
        }
        if (AbilityCenter.shared.storage[AnyHashable(otherDefaultFuncStringToInt)] != nil) {
            AbilityCenter.shared.removeFuncWithKey(otherDefaultFuncStringToInt)
        }
        if (AbilityCenter.shared.storage[AnyHashable(otherDefaultFuncVoidToInt)] != nil) {
            AbilityCenter.shared.removeFuncWithKey(otherDefaultFuncVoidToInt)
        }
        
        AbilityCenter.shared.register(otherFuncStringToInt, block: Funcs.otherStringToInt)
        XCTAssertEqual(otherFuncStringToInt.description, "otherFuncStringToInt(String) -> Int")
        XCTAssertNotNil(AbilityCenter.shared.storage[AnyHashable(otherFuncStringToInt)] as? (String) -> Int)
        
        AbilityCenter.shared.register(otherFuncVoidToInt, block: Funcs.otherVoidToInt)
        XCTAssertNotNil(AbilityCenter.shared.storage[AnyHashable(otherFuncVoidToInt)] as? () -> Int)
        
        AbilityCenter.shared.register(otherDefaultFuncStringToInt, block: Funcs.otherStringToInt)
        XCTAssertEqual(otherDefaultFuncStringToInt.description, "otherFuncStringToInt(String) -> Int")
        XCTAssertNotNil(AbilityCenter.shared.storage[AnyHashable(otherDefaultFuncStringToInt.funcKey)] as? (String) -> Int)
        
        AbilityCenter.shared.register(otherDefaultFuncVoidToInt, block: Funcs.otherVoidToInt)
        XCTAssertNotNil(AbilityCenter.shared.storage[AnyHashable(otherDefaultFuncVoidToInt)] as? () -> Int)
    }
    
    func testExecuteFuncs() {
        let stringToIntResult = Ability.execute(funcStringToInt, params: "1")
        XCTAssertEqual(stringToIntResult, 1)
        
        XCTAssertFalse(Funcs.stringToVoidGetCall)
        Ability.execute(funcStringToVoid, params: "1")
        XCTAssertTrue(Funcs.stringToVoidGetCall)
        
        let voidToIntResult = Ability.execute(funcVoidToInt)
        XCTAssertEqual(Funcs.voidToIntValue, voidToIntResult)
        
        XCTAssertFalse(Funcs.voidToVoidGetCall)
        Ability.execute(funcVoidToVoid)
        XCTAssertTrue(Funcs.voidToVoidGetCall)
        
        XCTAssertFalse(Funcs.stringToOptionalIntGetCall)
        var stringToOptionalIntResult = Ability.execute(funcStringToOptionalInt, params: "1")
        XCTAssertTrue(Funcs.stringToOptionalIntGetCall)
        XCTAssertEqual(stringToOptionalIntResult, Optional<Int>.some(1))
        Funcs.stringToOptionalIntGetCall = false
        stringToOptionalIntResult = Ability.execute(funcStringToOptionalInt, params: "a")
        XCTAssertTrue(Funcs.stringToOptionalIntGetCall)
        XCTAssertEqual(stringToOptionalIntResult, Optional<Int>.none)
        
        XCTAssertFalse(Funcs.voidToOptionalIntGetCall)
        let voidToOptionalIntResult = Ability.execute(funcVoidToOptionalInt)
        
        XCTAssertTrue(Funcs.voidToOptionalIntGetCall)
        XCTAssertEqual(voidToOptionalIntResult, Optional<Int>.none)
        Funcs.voidToOptionalIntGetCall = false
        Funcs.voidToOptionalIntValue = 1
        stringToOptionalIntResult = Ability.execute(funcVoidToOptionalInt)
        XCTAssertTrue(Funcs.voidToOptionalIntGetCall)
        XCTAssertNotNil(type(of: stringToOptionalIntResult).wrappedType as? Int.Type)
        XCTAssertEqual(stringToOptionalIntResult.wrappedValue as? Int, 1)
        XCTAssertEqual(stringToOptionalIntResult, Optional<Int>.some(1))
    }
    
    func testExecuteFuncsWithDefault() {
        XCTAssertFalse(defaultFuncStringToIntGetCall)
        let stringToIntResult = Ability.execute(defaultFuncStringToInt, params: "2")
        XCTAssertEqual(stringToIntResult, 1)
        XCTAssertTrue(defaultFuncStringToIntGetCall)
        
        XCTAssertFalse(defaultFuncStringToVoidGetCall)
        Ability.execute(defaultFuncStringToVoid, params: "1")
        XCTAssertTrue(defaultFuncStringToVoidGetCall)
        
        XCTAssertFalse(defaultFuncVoidToIntGetCall)
        let voidToIntResult = Ability.execute(defaultFuncVoidToInt)
        XCTAssertEqual(voidToIntResult, 1)
        XCTAssertTrue(defaultFuncVoidToIntGetCall)
        
        XCTAssertFalse(defaultFuncVoidToVoidGetCall)
        Ability.execute(defaultFuncVoidToVoid)
        XCTAssertTrue(defaultFuncVoidToVoidGetCall)
        
        XCTAssertFalse(defaultFuncStringToOptionalIntGetCall)
        let stringToOptionalIntResult = Ability.execute(defaultFuncStringToOptionalInt, params: "2")
        XCTAssertTrue(defaultFuncStringToOptionalIntGetCall)
        XCTAssertEqual(stringToOptionalIntResult, Optional<Int>.some(1))
        
        XCTAssertFalse(defaultFuncVoidToOptionalIntGetCall)
        let voidToOptionalIntResult = Ability.execute(defaultFuncVoidToOptionalInt)
        XCTAssertTrue(defaultFuncVoidToOptionalIntGetCall)
        XCTAssertEqual(voidToOptionalIntResult, 1)
    }
    
    func testRemoveFuncWithKey() {
        if (AbilityCenter.shared.storage[AnyHashable(otherFuncStringToInt)] == nil) {
            AbilityCenter.shared.register(otherFuncStringToInt, block: Funcs.otherStringToInt)
        }
        
        XCTAssertNotNil(AbilityCenter.shared.storage[AnyHashable(otherFuncStringToInt)] as? (String) -> Int)
        AbilityCenter.shared.removeFuncWithKey(otherFuncStringToInt)
        XCTAssertNil(AbilityCenter.shared.storage[AnyHashable(otherFuncStringToInt)] as? (String) -> Int)
    }
    
    func testFuncDuplicateRegiste() {
        AbilityMonitor.shared.arrObservers = []
        final class Oberver: AbilityMonitorObserver, @unchecked Sendable {
            var duplicateRegisterGetCall: Bool = false
            func receiveAbilityEvent(_ event: AbilityEvent) {
                if case .duplicateRegisteFunc(_, _, _)  = event {
                    duplicateRegisterGetCall = true
                }
            }
        }
        let oberver = Oberver()
        let cancellable = AbilityMonitor.shared.addObserver(oberver)
        
        if (AbilityCenter.shared.storage[AnyHashable(otherFuncStringToInt)] == nil) {
            AbilityCenter.shared.register(otherFuncStringToInt, block: Funcs.otherStringToInt)
        }
        
        XCTAssertFalse(oberver.duplicateRegisterGetCall)
        
        AbilityCenter.shared.register(otherFuncStringToInt, block: Funcs.otherStringToInt)
        XCTAssertTrue(oberver.duplicateRegisterGetCall)
        
        oberver.duplicateRegisterGetCall = false
        if (AbilityCenter.shared.storage[AnyHashable(otherFuncVoidToInt)] == nil) {
            AbilityCenter.shared.register(otherFuncVoidToInt, block: Funcs.otherVoidToInt)
        }
        AbilityCenter.shared.register(otherFuncVoidToInt, block: Funcs.otherVoidToInt)
        XCTAssertTrue(oberver.duplicateRegisterGetCall)
        
        cancellable.cancel()
    }
    
    func testExecuteFuncNotFound() {
        AbilityMonitor.shared.arrObservers = []
        final class Oberver: AbilityMonitorObserver, @unchecked Sendable {
            var funcNotFoundGetCall: Bool = false
            func receiveAbilityEvent(_ event: AbilityEvent) {
                if case .funcNotFoundWithKey(_) = event {
                    funcNotFoundGetCall = true
                }
            }
        }
        let oberver = Oberver()
        let cancellable = AbilityMonitor.shared.addObserver(oberver)
        
        if (AbilityCenter.shared.storage[AnyHashable(otherFuncStringToInt)] != nil) {
            AbilityCenter.shared.removeFuncWithKey(otherFuncStringToInt)
        }
        if (AbilityCenter.shared.storage[AnyHashable(otherFuncStringToInt)] != nil) {
            AbilityCenter.shared.removeFuncWithKey(otherFuncVoidToInt)
        }
        
        XCTAssertFalse(oberver.funcNotFoundGetCall)
        _ = Ability.execute(otherFuncStringToInt, params: "1")
        XCTAssertTrue(oberver.funcNotFoundGetCall)
        
        oberver.funcNotFoundGetCall = false
        _ = Ability.execute(otherFuncVoidToInt)
        XCTAssertTrue(oberver.funcNotFoundGetCall)
        
        oberver.funcNotFoundGetCall = false
        Ability.execute(otherFuncStringToVoid, params: "1")
        XCTAssertTrue(oberver.funcNotFoundGetCall)
        
        oberver.funcNotFoundGetCall = false
        Ability.execute(otherFuncVoidToVoid)
        XCTAssertTrue(oberver.funcNotFoundGetCall)
        
        oberver.funcNotFoundGetCall = false
        _ = Ability.execute(otherFuncStringToOptionalInt, params: "1")
        XCTAssertTrue(oberver.funcNotFoundGetCall)
        
        oberver.funcNotFoundGetCall = false
        _ = Ability.execute(otherFuncVoidToOptionalInt)
        XCTAssertTrue(oberver.funcNotFoundGetCall)
        
        cancellable.cancel()
    }
    
    func testFuncRegisteAfterLoad() {
        let oldAppConfig = g_appConfig
        g_appConfig = [AnyHashable(ConfigKey.abilityConfig): AbilityConfig(blockFuncRegisteAfterLoad: true)]
        
        AbilityMonitor.shared.arrObservers = []
        final class Oberver: AbilityMonitorObserver, @unchecked Sendable {
            var blockFuncRegisteAfterLoadGetCall: Bool = false
            func receiveAbilityEvent(_ event: AbilityEvent) {
                if case .blockFuncRegisteAfterLoad(_, _) = event {
                    blockFuncRegisteAfterLoadGetCall = true
                }
            }
        }
        let oberver = Oberver()
        let cancellable = AbilityMonitor.shared.addObserver(oberver)
        
        let abilityCenter = AbilityCenter()
        abilityCenter.load()
        abilityCenter.load()
        
        XCTAssertFalse(oberver.blockFuncRegisteAfterLoadGetCall)
        abilityCenter.register(funcStringToInt, block: Funcs.stringToInt)
        XCTAssertTrue(oberver.blockFuncRegisteAfterLoadGetCall)
        
        oberver.blockFuncRegisteAfterLoadGetCall = false
        abilityCenter.register(funcVoidToInt, block: Funcs.voidToInt)
        XCTAssertTrue(oberver.blockFuncRegisteAfterLoadGetCall)
        
        cancellable.cancel()
        g_appConfig = oldAppConfig
    }
    
    func testFuncRemoveAfterLoad() {
        let oldAppConfig = g_appConfig
        g_appConfig = [AnyHashable(ConfigKey.abilityConfig): AbilityConfig(blockFuncRegisteAfterLoad: true, funcs: [.init(funcStringToInt, Funcs.stringToInt)])]
        
        AbilityMonitor.shared.arrObservers = []
        final class Oberver: AbilityMonitorObserver, @unchecked Sendable {
            var blockFuncRemoveAfterLoadGetCall: Bool = false
            func receiveAbilityEvent(_ event: AbilityEvent) {
                if case .blockFuncRemoveAfterLoad(_) = event {
                    blockFuncRemoveAfterLoadGetCall = true
                }
            }
        }
        let oberver = Oberver()
        let cancellable = AbilityMonitor.shared.addObserver(oberver)
        
        let abilityCenter = AbilityCenter()
        abilityCenter.load()

        XCTAssertFalse(oberver.blockFuncRemoveAfterLoadGetCall)
        abilityCenter.removeFuncWithKey(funcStringToInt)
        XCTAssertTrue(oberver.blockFuncRemoveAfterLoadGetCall)
        
        cancellable.cancel()
        g_appConfig = oldAppConfig
    }
}
