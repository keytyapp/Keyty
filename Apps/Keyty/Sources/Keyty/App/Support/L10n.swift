//
//  L10n.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

#if APP_STORE
typealias L10n = KeytyAppStoreStrings.Localizable
#else
typealias L10n = KeytyStrings.Localizable
#endif
