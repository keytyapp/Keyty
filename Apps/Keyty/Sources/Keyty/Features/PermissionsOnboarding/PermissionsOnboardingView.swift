//
//  PermissionsOnboardingView.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit
import SwiftUI

struct PermissionsOnboardingView: View {
    @ObservedObject var viewModel: PermissionsOnboardingViewModel

    var body: some View {
        VStack(spacing: Spacing.sm) {
            self.header
            self.permissionsCard
            self.privacyNote
            Spacer(minLength: Spacing.none)
            self.footer
        }
        .padding(.horizontal, Spacing.grid(6))
        .padding(.top, Spacing.grid(7))
        .padding(.bottom, Spacing.grid(5))
        .frame(width: Size.Window.permissionsOnboarding.width)
        .frame(minHeight: Size.Window.permissionsOnboarding.height, maxHeight: .infinity, alignment: .top)
        .background(VisualEffectView(material: .hudWindow))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg + Spacing.unit, style: .continuous)
                .stroke(Color.Theme.Border.primary, lineWidth: StrokeWidth.standard)
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg + Spacing.unit, style: .continuous))
        .ignoresSafeArea(edges: .top)
    }

    private var header: some View {
        VStack(spacing: Spacing.sm) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Spacing.grid(16), height: Spacing.grid(16))
                .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
                .shadow(color: Color.Theme.Shadow.iconBadgeSelected, radius: 8, y: 3)

            VStack(spacing: .zero) {
                Text(L10n.PermissionsOnboarding.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.Theme.Text.primary)

                Text(L10n.PermissionsOnboarding.subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.Theme.Text.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(Spacing.none)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var permissionsCard: some View {
        VStack(spacing: Spacing.none) {
            self.permissionRow(
                iconName: "keyboard",
                iconBackgroundColor: Color.Theme.Accent.controlAccent,
                title: L10n.PermissionsOnboarding.InputMonitoring.title,
                detail: L10n.PermissionsOnboarding.InputMonitoring.detail,
                status: self.viewModel.inputMonitoringStatus,
                buttonTitle: L10n.PermissionsOnboarding.InputMonitoring.grantButton,
                action: self.viewModel.requestInputMonitoring
            )
            self.permissionRow(
                iconName: "accessibility",
                iconBackgroundColor: Color.Theme.Accent.controlAccent,
                title: L10n.PermissionsOnboarding.Accessibility.title,
                detail: L10n.PermissionsOnboarding.Accessibility.detail,
                status: self.viewModel.accessibilityStatus,
                buttonTitle: L10n.PermissionsOnboarding.Accessibility.grantButton,
                action: self.viewModel.requestAccessibility
            )
        }
        .padding(.horizontal, Spacing.grid(4))
        .background(self.cardBackground)
    }

    private var privacyNote: some View {
        HStack(spacing: Spacing.none) {
            Text(L10n.PermissionsOnboarding.privacy)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.Theme.Text.secondary)
                .lineSpacing(Spacing.none)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer(minLength: Spacing.none)
        }
        .padding(.horizontal, Spacing.grid(4))
    }

    private var footer: some View {
        ZStack {
            HStack {
                Button(action: self.viewModel.openLearnMore) {
                    Text(L10n.PermissionsOnboarding.learnMore)
                        .font(.system(size: 13, weight: .regular))
                        .underline()
                }
                .buttonStyle(.plain)
                .foregroundColor(Color.Theme.Accent.controlAccent)

                Spacer(minLength: Spacing.none)
            }

            Button(L10n.PermissionsOnboarding.continue, action: self.viewModel.continueIfComplete)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
                .disabled(!self.viewModel.isComplete)
                .frame(width: Spacing.grid(42))
        }
        .frame(maxWidth: .infinity)
    }

    private func permissionRow(
        iconName: String,
        iconBackgroundColor: Color,
        title: String,
        detail: String,
        status: Permission.Status,
        buttonTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .center, spacing: Spacing.grid(4)) {
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(Color.Theme.Brand.white)
                .frame(width: Spacing.grid(10), height: Spacing.grid(10))
                .background(
                    RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                        .fill(iconBackgroundColor)
                )

            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.Theme.Text.primary)

                Text(detail)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.Theme.Text.secondary)
                    .lineSpacing(Spacing.none)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if status == .granted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color.Theme.State.success)
                    .frame(width: Spacing.grid(64), alignment: .trailing)
            } else {
                Button(buttonTitle, action: action)
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .frame(width: Spacing.grid(42), alignment: .trailing)
            }
        }
        .padding(.vertical, Spacing.sm)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: Radius.lg + Spacing.unit, style: .continuous)
            .fill(Color.Theme.Brand.white.opacity(0.04))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg + Spacing.unit, style: .continuous)
                    .stroke(Color.Theme.Border.primary, lineWidth: StrokeWidth.standard)
            )
    }

}
