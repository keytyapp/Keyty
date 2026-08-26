//
//  M0116KeycapMetrics.swift
//  Keyty
//
//  SPDX-FileCopyrightText: 2026 Serhii Bykov
//  SPDX-License-Identifier: BSD-3-Clause
//

import AppKit

/// Proportions traced from an Apple Standard Keyboard (M0116): square-ish caps on an
/// 82pt pitch, a face inset from the sculpted sides, and a tall lit skirt at the front.
enum M0116KeycapMetrics {
    static let height: CGFloat = 88
    static let minWidth: CGFloat = 80
    static let itemSpacing: CGFloat = 6
    static let groupPadding = NSEdgeInsets(top: 11, left: 11, bottom: 11, right: 11)
    static let repeatBadgeInset = CGPoint(x: 6, y: 6)

    static let bodyCornerRadius: CGFloat = 9
    static let faceCornerRadius: CGFloat = 7
    static let faceSideInset: CGFloat = 5
    static let faceTopInset: CGFloat = 4
    static let faceBottomInset: CGFloat = 15
    static let horizontalPadding: CGFloat = 11
    static let capsLockLabelWidth: CGFloat = 52
    static let legendBaselineInset: CGFloat = 6
    static let pressedTravel: CGFloat = 2

    /// The near-black well each cap sits in. Half the item spacing on each side, so
    /// neighbouring wells meet and read as one continuous plate.
    static let wellSideInset: CGFloat = 3
    static let wellBottomInset: CGFloat = 3.5
    static let wellTopInset: CGFloat = 1.5

    /// The original caps were printed in Univers 57 Condensed Oblique. Univers is a
    /// licensed Linotype family that macOS does not ship, so it is used when the user
    /// happens to have it installed and otherwise stood in for by condensing a Helvetica
    /// oblique — the closest neo-grotesque available on every Mac.
    struct LegendFace {
        let name: String
        /// Horizontal scale applied to reach Univers 57's condensed width. Faces that are
        /// already condensed use 1.
        let condensation: CGFloat
    }

    static let legendFaces: [LegendFace] = [
        LegendFace(name: "Univers-CondensedOblique", condensation: 1),
        LegendFace(name: "UniversLTStd-CnObl", condensation: 1),
        LegendFace(name: "HelveticaNeue-Italic", condensation: 0.82),
        LegendFace(name: "Helvetica-Oblique", condensation: 0.82),
        LegendFace(name: "HelveticaNeue-LightItalic", condensation: 0.82),
        LegendFace(name: "Helvetica-LightOblique", condensation: 0.82),
    ]

    static func legendFont(ofSize size: CGFloat) -> NSFont {
        for face in self.legendFaces {
            guard NSFont(name: face.name, size: size) != nil else { continue }
            if face.condensation == 1 {
                return NSFont(name: face.name, size: size) ?? NSFont.systemFont(ofSize: size)
            }
            let matrix = AffineTransform(scaleByX: size * face.condensation, byY: size)
            let descriptor = NSFontDescriptor(fontAttributes: [.name: face.name, .matrix: matrix])
            if let font = NSFont(descriptor: descriptor, size: 0) {
                return font
            }
        }

        let descriptor = NSFont.systemFont(ofSize: size)
            .fontDescriptor
            .withSymbolicTraits([.italic, .condensed])
        return NSFont(descriptor: descriptor, size: size) ?? NSFont.systemFont(ofSize: size)
    }

    static var charFont: NSFont { self.legendFont(ofSize: 24) }
    static var labelFont: NSFont { self.legendFont(ofSize: 19) }
    static var symbolFont: NSFont { self.legendFont(ofSize: 23) }
}
