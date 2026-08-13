//
//  Project.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import ProjectDescription

let appSettings: SettingsDictionary = [
    "ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS": "YES",
    "CLANG_ENABLE_OBJC_WEAK": "YES",
    "CODE_SIGN_ENTITLEMENTS": "Sources/Keyty/Resources/Keyty.entitlements",
    "CURRENT_PROJECT_VERSION": "120",
    "DEAD_CODE_STRIPPING": "YES",
    "ENABLE_HARDENED_RUNTIME": "YES",
    "FRAMEWORK_SEARCH_PATHS": [
        "$(inherited)",
        "$(SRCROOT)",
        "$(PROJECT_DIR)",
    ],
    "INFOPLIST_FILE": "Sources/Keyty/Resources/Info.plist",
    "INFOPLIST_KEY_CFBundleDisplayName": "Keyty",
    "INSTALL_PATH": "$(HOME)/Applications",
    "SPARKLE_FEED_URL": "https://keyty.app/appcast.xml",
    "LD_RUNPATH_SEARCH_PATHS": [
        "$(inherited)",
        "@executable_path/../Frameworks",
    ],
    "MARKETING_VERSION": "1.2.0",
    "PRODUCT_BUNDLE_IDENTIFIER": "app.keyty.Keyty",
    "PRODUCT_NAME": "Keyty",
    "PROVISIONING_PROFILE_SPECIFIER": "",
    "SWIFT_VERSION": "5.0",
    "WRAPPER_EXTENSION": "app",
]

let appDebugSettings: SettingsDictionary = [
    "CODE_SIGN_IDENTITY": "Apple Development",
    "CODE_SIGN_STYLE": "Automatic",
    "DEVELOPMENT_TEAM": "NEVA4MAZBL",
    "COPY_PHASE_STRIP": "NO",
    "GCC_DYNAMIC_NO_PIC": "NO",
    "GCC_MODEL_TUNING": "G5",
    "GCC_OPTIMIZATION_LEVEL": "0",
    "ZERO_LINK": "YES",
]

let appReleaseSettings: SettingsDictionary = [
    "CODE_SIGN_IDENTITY": "Developer ID Application",
    "CODE_SIGN_STYLE": "Manual",
    "DEVELOPMENT_TEAM": "",
    "DEVELOPMENT_TEAM[sdk=macosx*]": "NEVA4MAZBL",
    "GCC_MODEL_TUNING": "G5",
]

let testSettings: SettingsDictionary = [
    "BUNDLE_LOADER": "$(TEST_HOST)",
    "CLANG_ANALYZER_NONNULL": "YES",
    "CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION": "YES_AGGRESSIVE",
    "CLANG_CXX_LANGUAGE_STANDARD": "gnu++14",
    "CLANG_CXX_LIBRARY": "libc++",
    "CLANG_ENABLE_MODULES": "YES",
    "CLANG_ENABLE_OBJC_ARC": "YES",
    "CLANG_ENABLE_OBJC_WEAK": "YES",
    "CLANG_WARN_DIRECT_OBJC_ISA_USAGE": "YES_ERROR",
    "CLANG_WARN_DOCUMENTATION_COMMENTS": "YES",
    "CLANG_WARN_OBJC_ROOT_CLASS": "YES_ERROR",
    "CLANG_WARN_UNGUARDED_AVAILABILITY": "YES_AGGRESSIVE",
    // Must match the host app's team: macOS refuses to load a test bundle whose
    // Team ID differs from the process it is injected into.
    "CODE_SIGN_IDENTITY": "Apple Development",
    "CODE_SIGN_STYLE": "Automatic",
    "DEVELOPMENT_TEAM": "NEVA4MAZBL",
    "COMBINE_HIDPI_IMAGES": "YES",
    "COPY_PHASE_STRIP": "NO",
    "DEAD_CODE_STRIPPING": "YES",
    "GCC_C_LANGUAGE_STANDARD": "gnu11",
    "GCC_WARN_ABOUT_RETURN_TYPE": "YES_ERROR",
    "GCC_WARN_UNINITIALIZED_AUTOS": "YES_AGGRESSIVE",
    "HEADER_SEARCH_PATHS": "$(SRCROOT)",
    "INFOPLIST_FILE": "Tests/KeytyTests/Info.plist",
    "LD_RUNPATH_SEARCH_PATHS": [
        "$(inherited)",
        "@executable_path/../Frameworks",
        "@loader_path/../Frameworks",
    ],
    "MTL_FAST_MATH": "YES",
    "PRODUCT_BUNDLE_IDENTIFIER": "app.keyty.KeytyTests",
    "PRODUCT_NAME": "KeytyTests",
    "SWIFT_VERSION": "5.0",
    "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/Keyty.app/Contents/MacOS/Keyty",
]

let testDebugSettings: SettingsDictionary = [
    "DEBUG_INFORMATION_FORMAT": "dwarf",
    "GCC_DYNAMIC_NO_PIC": "NO",
    "GCC_OPTIMIZATION_LEVEL": "0",
    "GCC_PREPROCESSOR_DEFINITIONS": [
        "DEBUG=1",
        "$(inherited)",
    ],
    "MTL_ENABLE_DEBUG_INFO": "INCLUDE_SOURCE",
]

let testReleaseSettings: SettingsDictionary = [
    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
    "ENABLE_NS_ASSERTIONS": "NO",
    "MTL_ENABLE_DEBUG_INFO": "NO",
]

let projectSettings = Settings.settings(
    base: [
        "ALWAYS_SEARCH_USER_PATHS": "NO",
        "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
        "CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED": "YES",
        "CLANG_ENABLE_OBJC_ARC": "YES",
        "CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING": "YES",
        "CLANG_WARN_BOOL_CONVERSION": "YES",
        "CLANG_WARN_COMMA": "YES",
        "CLANG_WARN_CONSTANT_CONVERSION": "YES",
        "CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS": "YES",
        "CLANG_WARN_EMPTY_BODY": "YES",
        "CLANG_WARN_ENUM_CONVERSION": "YES",
        "CLANG_WARN_INFINITE_RECURSION": "YES",
        "CLANG_WARN_INT_CONVERSION": "YES",
        "CLANG_WARN_NON_LITERAL_NULL_CONVERSION": "YES",
        "CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF": "YES",
        "CLANG_WARN_OBJC_LITERAL_CONVERSION": "YES",
        "CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": "YES",
        "CLANG_WARN_RANGE_LOOP_ANALYSIS": "YES",
        "CLANG_WARN_STRICT_PROTOTYPES": "YES",
        "CLANG_WARN_SUSPICIOUS_MOVE": "YES",
        "CLANG_WARN_UNREACHABLE_CODE": "YES",
        "CLANG_WARN__DUPLICATE_METHOD_MATCH": "YES",
        "DEAD_CODE_STRIPPING": "YES",
        "ENABLE_STRICT_OBJC_MSGSEND": "YES",
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
        "GCC_GENERATE_TEST_COVERAGE_FILES": "NO",
        "GCC_NO_COMMON_BLOCKS": "YES",
        "GCC_WARN_64_TO_32_BIT_CONVERSION": "YES",
        "GCC_WARN_ABOUT_RETURN_TYPE": "YES",
        "GCC_WARN_UNDECLARED_SELECTOR": "YES",
        "GCC_WARN_UNINITIALIZED_AUTOS": "YES",
        "GCC_WARN_UNUSED_FUNCTION": "YES",
        "GCC_WARN_UNUSED_VARIABLE": "YES",
        "MACOSX_DEPLOYMENT_TARGET": "11.0",
        "SDKROOT": "macosx",
        "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
    ],
    configurations: [
        .debug(
            name: "Debug",
            settings: [
                "ENABLE_TESTABILITY": "YES",
                "MTL_ENABLE_DEBUG_INFO": "INCLUDE_SOURCE",
                "ONLY_ACTIVE_ARCH": "YES",
            ]
        ),
        .release(
            name: "Release",
            settings: [
                "SWIFT_COMPILATION_MODE": "wholemodule",
            ]
        ),
    ]
)

let project = Project(
    name: "Keyty",
    organizationName: "Keyty",
    options: .options(
        defaultKnownRegions: ["de", "en", "es", "fr", "ja", "nl", "uk", "zh-Hans"],
        developmentRegion: "en"
    ),
    packages: [
        .remote(
            url: "https://github.com/Kentzo/ShortcutRecorder",
            requirement: .exact("3.4.0")
        ),
        .remote(
            url: "https://github.com/sparkle-project/Sparkle",
            requirement: .exact("2.9.4")
        ),
        .remote(
            url: "https://github.com/linearmouse/AppMover",
            requirement: .revision("a578bf41b8d4874eb6b9ace05608f217f52efcb0")
        ),
        .remote(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            requirement: .exact("1.19.2")
        ),
    ],
    settings: projectSettings,
    targets: [
        .target(
            name: "Keyty",
            destinations: .macOS,
            product: .app,
            bundleId: "app.keyty.Keyty",
            deploymentTargets: .macOS("11.0"),
            infoPlist: .file(path: "Sources/Keyty/Resources/Info.plist"),
            buildableFolders: [
                .folder(
                    "Sources/Keyty",
                    exceptions: [.exception(excluded: ["Resources/Info.plist"])]
                ),
            ],
            entitlements: .file(path: "Sources/Keyty/Resources/Keyty.entitlements"),
            dependencies: [
                .sdk(name: "Cocoa", type: .framework),
                .sdk(name: "Quartz", type: .framework),
                .sdk(name: "QuartzCore", type: .framework),
                .sdk(name: "Carbon", type: .framework),
                .package(product: "ShortcutRecorder"),
                .package(product: "Sparkle"),
                .package(product: "AppMover"),
            ],
            settings: .settings(
                base: appSettings,
                configurations: [
                    .debug(name: "Debug", settings: appDebugSettings),
                    .release(name: "Release", settings: appReleaseSettings),
                ]
            )
        ),
        .target(
            name: "KeytyTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "app.keyty.KeytyTests",
            deploymentTargets: .macOS("11.0"),
            infoPlist: .file(path: "Tests/KeytyTests/Info.plist"),
            buildableFolders: [
                .folder(
                    "Tests/KeytyTests",
                    exceptions: [.exception(excluded: ["Info.plist"])]
                ),
            ],
            dependencies: [
                .target(name: "Keyty"),
                .package(product: "SnapshotTesting"),
            ],
            settings: .settings(
                base: testSettings,
                configurations: [
                    .debug(name: "Debug", settings: testDebugSettings),
                    .release(name: "Release", settings: testReleaseSettings),
                ]
            )
        ),
    ],
    schemes: [
        .scheme(
            name: "Keyty",
            shared: true,
            buildAction: .buildAction(targets: ["Keyty"]),
            testAction: .targets(
                ["KeytyTests"],
                configuration: .debug
            ),
            runAction: .runAction(configuration: .debug),
            archiveAction: .archiveAction(configuration: .release),
            profileAction: .profileAction(configuration: .release),
            analyzeAction: .analyzeAction(configuration: .debug)
        ),
    ],
    resourceSynthesizers: [
        .custom(
            name: "L10n",
            parser: .strings,
            extensions: ["strings", "stringsdict"]
        ),
    ]
)
