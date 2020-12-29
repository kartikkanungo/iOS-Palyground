import UIKit
import SwiftUI


class URLBuilder1 {
    var components: URLComponents
    init() {
        self.components = URLComponents()
    }
}

let urlBuilder1 = URLBuilder1()
urlBuilder1.components.scheme = "https"
urlBuilder1.components.host = "localhost"



// MARK:- The Builder Pattern
class URLBuilder {

    var components: URLComponents

    init() {
        self.components = URLComponents()
    }

    func set(scheme: String) -> URLBuilder {
        self.components.scheme = scheme
        return self
    }

    func set(host: String) -> URLBuilder {
        self.components.host = host
        return self
    }

    func set(port: Int) -> URLBuilder {
        self.components.port = port
        return self
    }

    func set(path: String) -> URLBuilder {
        var path = path
        if !path.hasPrefix("/") {
            path = "/" + path
        }
        self.components.path = path
        return self
    }

    func addQueryItem(name: String, value: String) -> URLBuilder  {
        if self.components.queryItems == nil {
            self.components.queryItems = []
        }
        self.components.queryItems?.append(URLQueryItem(name: name, value: value))
        return self
    }

    func build() -> URL? {
        return self.components.url
    }
}

let url = URLBuilder()
    .set(scheme: "https")
    .set(host: "localhost")
    .set(path: "api/v1")
    .addQueryItem(name: "sort", value: "name")
    .addQueryItem(name: "order", value: "asc")
    .build()


// MARK:- function Builder

struct Setting {
    var name: String
    var value: Value
    
    enum Value {
        case bool(Bool)
        case int(Int)
        case string(String)
        case group([Setting])
    }
}

let settings = [
    Setting(name: "Offline mode", value: .bool(false)),
    Setting(name: "Search page size", value: .int(25)),
    Setting(name: "Experimental", value: .group([
        Setting(name: "Default name", value: .string("Untitled")),
        Setting(name: "Fluid animations", value: .bool(true))
    ]))
]

// Creting a Function Builder
@_functionBuilder
struct SettingsBuilder {
    static func buildBlock() -> [Setting] { [] }
}

func makeSettings(@SettingsBuilder _ content: () -> [Setting]) {
    content()
}

let settings1 = makeSettings {
    
}

extension SettingsBuilder {
    static func buildBlock(_ settings: Setting...) -> [Setting] {
        settings
    }
}

let settings2 = makeSettings {
    Setting(name: "Offline mode", value: .bool(false))
    Setting(name: "Search page size", value: .int(25))

    Setting(name: "Experimental", value: .group([
        Setting(name: "Default name", value: .string("Untitled")),
        Setting(name: "Fluid animations", value: .bool(true))
    ]))
}

struct SettingsGroup {
    var name: String
    var settings: [Setting]

    init(name: String,
         @SettingsBuilder builder: () -> [Setting]) {
        self.name = name
        self.settings = builder()
    }
}

SettingsGroup(name: "Experimental") {
    Setting(name: "Default name", value: .string("Untitled"))
    Setting(name: "Fluid animations", value: .bool(true))
}


protocol SettingsConvertible {
    func asSettings() -> [Setting]
}

extension Setting: SettingsConvertible {
    func asSettings() -> [Setting] { [self] }
}

extension SettingsGroup: SettingsConvertible {
    func asSettings() -> [Setting] {
        [Setting(name: name, value: .group(settings))]
    }
}

extension SettingsBuilder {
    static func buildBlock(_ values: SettingsConvertible...) -> [Setting] {
        values.flatMap { $0.asSettings() }
    }
}

let settings3 = makeSettings {
    Setting(name: "Offline mode", value: .bool(false))
    Setting(name: "Search page size", value: .int(25))

    SettingsGroup(name: "Experimental") {
        Setting(name: "Default name", value: .string("Untitled"))
        Setting(name: "Fluid animations", value: .bool(true))
    }
}





// Conditionals

extension Array: SettingsConvertible where Element == Setting {
    func asSettings() -> [Setting] { self }
}

extension SettingsBuilder {
    static func buildIf(_ value: SettingsConvertible?) -> SettingsConvertible {
        value ?? []
    }
}

extension SettingsBuilder {
    static func buildEither(first: SettingsConvertible) -> SettingsConvertible {
        first
    }

    static func buildEither(second: SettingsConvertible) -> SettingsConvertible {
        second
    }
}

let shouldShowExperimental: Bool = true

let settings4 = makeSettings {
    Setting(name: "Offline mode", value: .bool(false))
    Setting(name: "Search page size", value: .int(25))

    // Compiler error: Closure containing control flow statement
    // cannot be used with function builder 'SettingsBuilder'.
    if shouldShowExperimental {
        SettingsGroup(name: "Experimental") {
            Setting(name: "Default name", value: .string("Untitled"))
            Setting(name: "Fluid animations", value: .bool(true))
        }
    } else {
        Setting(name: "Request experimental access", value: .bool(false))
    }
}

