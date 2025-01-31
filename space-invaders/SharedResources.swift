import UIKit
import SpriteKit

enum Colors {
    static let background = UIColor(hex: "000924")
    static let darkAccent = UIColor(hex: "041b38")
    static let midAccent = UIColor(hex: "093659")
    static let shipBase = UIColor(hex: "145d87")
    static let shipAccent = UIColor(hex: "228399")
    static let powerUp = UIColor(hex: "31b0b0")
    static let bulletColor = UIColor(hex: "46cfb3")
    static let scoreColor = UIColor(hex: "73f0c6")
    static let highlight = UIColor(hex: "abffd1")
    static let background2 = UIColor(hex: "d9ffe2")
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
    }
}

extension SKShapeNode {
    var glowWidth: CGFloat {
        get { return 0 }
        set {
            let effectNode = SKEffectNode()
            effectNode.shouldRasterize = true
            effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": newValue])

            let shape = SKShapeNode(path: self.path!)
            shape.fillColor = self.fillColor
            shape.strokeColor = self.strokeColor
            shape.lineWidth = self.lineWidth

            effectNode.addChild(shape)
            self.addChild(effectNode)
        }
    }
}