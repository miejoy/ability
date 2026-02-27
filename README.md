# Ability

Ability 属于基础能力模块，对外提供能力注册和能力获取功能，同时提供方法注册和方法执行功能

[![Swift](https://github.com/miejoy/ability/actions/workflows/test.yml/badge.svg)](https://github.com/miejoy/ability/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/miejoy/ability/branch/main/graph/badge.svg)](https://codecov.io/gh/miejoy/ability)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![Swift](https://img.shields.io/badge/swift-6.2-brightgreen.svg)](https://swift.org)

## 依赖

- iOS 13.0+ / macOS 10.15+
- Xcode 26.0+
- Swift 6.2+

## 简介

### 能力介绍
该模块提供基础能力协议 AbilityProtocol，外部可通过继承该协议来提供能力，也可通过 AbilityName 来获取对应能力

### 方法介绍
该模块提供方法的注册和执行能力，可以使用 FuncKey 作为方法的唯一标识，通过 FuncKey 来注册和执行方法。
这里还提供了一个有默认执行方法的 DefaultFuncKey，在没有找到注册方法时，将执行默认方法


## 安装

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

在项目中的 Package.swift 文件添加如下依赖:

```swift
dependencies: [
    .package(url: "https://github.com/miejoy/ability.git", from: "0.1.0"),
]
```

## 使用

### 能力使用

1、定义特定能力

```swift
import Ability

// 定义特定能力名称
let s_networkAbilityName = AbilityName(NetworkAbility.self)

// 定义特定能力
protocol NetworkAbility: AbilityProtocol {
    func doSomething()
}

// 特定能力绑定特定能力名称
extension NetworkAbility {
    static var abilityName: AbilityName { s_networkAbilityName }
}

// 定义特定能力对应默认能力
class DefaultNetworkAbility: NetworkAbility {
    // 实现对应能力方法
    func doSomething() {}
    
    // 在能力被加载时调用的方法，可在这里做一些方法注册的事情
    func load() {}
}
```

2、在 Ability 中扩展能力

```swift
import Ability

extension Ability {
    static var network : NetworkAbility = {
        Ability.getAbility(with: DefaultNetworkAbility()) as! NetworkAbility
    }()
}
```

3、自动注册能力

能力目前只提供自动注册方式，不提供手动代码注册，主要是为了避免一些用户不知道的能力被莫名注册了
这里使用 AutoConfig 提供的自动注册方式，必须在 ***主工程*** 中去注册

```swift
import Ability
import AutoConfig

class UserConfig: ConfigProtocol {

    static var configs: Set<ConfigPair> = [
        .init(.abilityConfig, abilityConfig)
    ]
}

let abilityConfig: AbilityConfig = {
    .init(
        abilities: [
            .init(DefaultNetworkAbility()),
        ]
    )
}()
```

3、使用能力

```swift
import Ability

// 使用 Ability 中扩展的能力（推荐）
Ability.network.doSomething()

// 直接获取能力使用
(Ability.getAbility(of: s_networkAbilityName) as? NetworkAbility)?.doSomething()
```

## 作者

Raymond.huang: raymond0huang@gmail.com

## License

Ability is available under the MIT license. See the LICENSE file for more info.

