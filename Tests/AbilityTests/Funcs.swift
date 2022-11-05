//
//  Funcs.swift
//  
//
//  Created by 黄磊 on 2022/10/29.
//

import Foundation
@testable import Ability

let funcStringToInt = FuncKey<String, Int>(funcId: "funcStringToInt")
let funcStringToVoid = FuncKey<String, Void>(funcId: "funcStringToVoid")
let funcVoidToInt = FuncKey<Void, Int>(funcId: "funcVoidToInt")
let funcVoidToVoid = FuncKey<Void, Void>(funcId: "funcStringToInt")
let funcStringToOptionalInt = FuncKey<String, Int?>(funcId: "funcStringToOptionalInt")
let funcVoidToOptionalInt = FuncKey<Void, Int?>(funcId: "funcVoidToOptionalInt")
let otherFuncStringToInt = FuncKey<String, Int>(funcId: "otherFuncStringToInt")
let otherFuncStringToVoid = FuncKey<String, Void>(funcId: "otherFuncStringToVoid")
let otherFuncVoidToInt = FuncKey<Void, Int>(funcId: "otherFuncVoidToInt")
let otherFuncVoidToVoid = FuncKey<Void, Void>(funcId: "otherFuncVoidToVoid")
let otherFuncStringToOptionalInt = FuncKey<String, Int?>(funcId: "otherFuncStringToOptionalInt")
let otherFuncVoidToOptionalInt = FuncKey<Void, Int?>(funcId: "otherFuncVoidToOptionalInt")

var defaultFuncStringToIntGetCall = false
var defaultFuncStringToVoidGetCall = false
var defaultFuncVoidToIntGetCall = false
var defaultFuncVoidToVoidGetCall = false
var defaultFuncStringToOptionalIntGetCall = false
var defaultFuncVoidToOptionalIntGetCall = false
var otherDefaultFuncStringToIntGetCall = false
var otherDefaultFuncStringToVoidGetCall = false
var otherDefaultFuncVoidToIntGetCall = false
var otherDefaultFuncVoidToVoidGetCall = false
var otherDefaultFuncStringToOptionalIntGetCall = false
var otherDefaultFuncVoidToOptionalIntGetCall = false

let defaultFuncStringToInt = DefaultFuncKey<String, Int>(funcId: "funcStringToInt") { _ in
    defaultFuncStringToIntGetCall = true
    return 1
}
let defaultFuncStringToVoid = DefaultFuncKey<String, Void>(funcId: "funcStringToVoid") { _ in
    defaultFuncStringToVoidGetCall = true
}
let defaultFuncVoidToInt = DefaultFuncKey<Void, Int>(funcId: "funcVoidToInt") {
    defaultFuncVoidToIntGetCall = true
    return 1
}
let defaultFuncVoidToVoid = DefaultFuncKey<Void, Void>(funcId: "funcStringToInt") {
    defaultFuncVoidToVoidGetCall = true
}
let defaultFuncStringToOptionalInt = DefaultFuncKey<String, Int?>(funcId: "funcStringToOptionalInt") { _ in
    defaultFuncStringToOptionalIntGetCall = true
    return 1
}
let defaultFuncVoidToOptionalInt = DefaultFuncKey<Void, Int?>(funcId: "funcVoidToOptionalInt") {
    defaultFuncVoidToOptionalIntGetCall = true
    return 1
}
let otherDefaultFuncStringToInt = DefaultFuncKey<String, Int>(funcId: "otherFuncStringToInt") { _ in
    otherDefaultFuncStringToIntGetCall = true
    return 1
}
let otherDefaultFuncStringToVoid = DefaultFuncKey<String, Void>(funcId: "otherFuncStringToVoid") { _ in
    otherDefaultFuncStringToVoidGetCall = true
}
let otherDefaultFuncVoidToInt = DefaultFuncKey<Void, Int>(funcId: "otherFuncVoidToInt") {
    otherDefaultFuncVoidToIntGetCall = true
    return 1
}
let otherDefaultFuncVoidToVoid = DefaultFuncKey<Void, Void>(funcId: "otherFuncVoidToVoid") {
    otherDefaultFuncVoidToVoidGetCall = true
}
let otherDefaultFuncStringToOptionalInt = DefaultFuncKey<String, Int?>(funcId: "otherFuncStringToOptionalInt") {  _ in
    otherDefaultFuncStringToOptionalIntGetCall = true
    return 1
}
let otherDefaultFuncVoidToOptionalInt = DefaultFuncKey<Void, Int?>(funcId: "otherFuncVoidToOptionalInt") {
    otherDefaultFuncVoidToOptionalIntGetCall = true
    return 1
}

enum Funcs {
    static func stringToInt(_ str: String) -> Int {
        Int(str)!
    }
    
    static var stringToVoidGetCall = false
    static func stringToVoid(_ str: String) {
        stringToVoidGetCall = true
    }
    
    static var voidToIntValue = 1
    static func voidToInt() -> Int {
        voidToIntValue
    }
    
    static var voidToVoidGetCall = false
    static func voidToVoid() {
        voidToVoidGetCall = true
    }
    
    static var stringToOptionalIntGetCall = false
    static func stringToOptionalInt(_ str: String) -> Int? {
        stringToOptionalIntGetCall = true
        return Int(str)
    }
    
    static var voidToOptionalIntGetCall = false
    static var voidToOptionalIntValue: Int? = nil
    static func voidToOptionalInt() -> Int? {
        voidToOptionalIntGetCall = true
        return voidToOptionalIntValue
    }
    
    static func otherStringToInt(_ str: String) -> Int { 1 }
    
    static func otherVoidToInt() -> Int { 1 }
}
