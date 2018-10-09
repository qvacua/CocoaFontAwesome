// FontAwesome.swift
//
// Copyright (c) 2014-present FontAwesome.swift contributors
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// Adapted for macOS by @hataewon
// Added trimming of transparent pixels and centering the image if the background color is clear.

import Cocoa
import CoreText

// MARK: - Public

/// A configuration namespace for FontAwesome.
public struct FontAwesomeConfig {

    // Marked private to prevent initialization of this struct.
    private init() { }

    /// Taken from FontAwesome.io's Fixed Width Icon CSS.
    public static let fontAspectRatio: CGFloat = 1.28571429
}

public enum FontAwesomeStyle: String {
    case solid
    case regular
    case brands

    func fontName() -> String {
        switch self {
        case .solid:
            return "FontAwesome5FreeSolid"
        case .regular:
            return "FontAwesome5FreeRegular"
        case .brands:
            return "FontAwesome5BrandsRegular"
        }
    }

    func fontFilename() -> String {
        switch self {
        case .solid:
            return "Font Awesome 5 Free-Solid-900"
        case .regular:
            return "Font Awesome 5 Free-Regular-400"
        case .brands:
            return "Font Awesome 5 Brands-Regular-400"
        }
    }

    func fontFamilyName() -> String {
        switch self {
        case .brands:
            return "Font Awesome 5 Brands"
        case .regular,
             .solid:
            return "Font Awesome 5 Free"
        }
    }
}

/// A FontAwesome extension to NSFont.
public extension NSFont {

    /// Get a NSFont object of FontAwesome.
    ///
    /// - parameter ofSize: The preferred font size.
    /// - returns: A NSFont object of FontAwesome.
    public class func fontAwesome(ofSize fontSize: CGFloat, style: FontAwesomeStyle) -> NSFont {
        loadFontAwesome(ofStyle: style)
        return NSFont(name: style.fontName(), size: fontSize)!
    }

    /// Loads the FontAwesome font in to memory.
    /// This method should be called when setting icons without using code.
    public class func loadFontAwesome(ofStyle style: FontAwesomeStyle) {
        let availableMembers = NSFontManager.shared.availableMembers(ofFontFamily: style.fontFamilyName())
        if let doesContain = availableMembers?.contains(where: { $0[0] as! String == style.fontName() }), doesContain {
            return
        }
//        if NSFont.fontNames(forFamilyName: style.fontFamilyName()).contains(style.fontName()) {
//            return
//        }

        FontLoader.loadFont(style.fontFilename())
    }
}

/// A FontAwesome extension to String.
public extension String {

    /// Get a FontAwesome icon string with the given icon name.
    ///
    /// - parameter name: The preferred icon name.
    /// - returns: A string that will appear as icon with FontAwesome.
    public static func fontAwesomeIcon(name: FontAwesome) -> String {
        let toIndex = name.rawValue.index(name.rawValue.startIndex, offsetBy: 1)
        return String(name.rawValue[name.rawValue.startIndex..<toIndex])
    }

    /// Get a FontAwesome icon string with the given CSS icon code. Icon code can be found here: http://fontawesome.io/icons/
    ///
    /// - parameter code: The preferred icon name.
    /// - returns: A string that will appear as icon with FontAwesome.
    public static func fontAwesomeIcon(code: String) -> String? {

        guard let name = self.fontAwesome(code: code) else {
            return nil
        }

        return self.fontAwesomeIcon(name: name)
    }

    /// Get a FontAwesome icon with the given CSS icon code. Icon code can be found here: http://fontawesome.io/icons/
    ///
    /// - parameter code: The preferred icon name.
    /// - returns: An internal corresponding FontAwesome code.
    public static func fontAwesome(code: String) -> FontAwesome? {
        guard let raw = FontAwesomeIcons[code] else { return nil }
        return FontAwesome(rawValue: raw)
    }
}

/// A FontAwesome extension to NSImage.
public extension NSImage {

      public static func fontAwesomeIcon(name: FontAwesome,
                                         style: FontAwesomeStyle,
                                         textColor: NSColor,
                                         dimension: CGFloat,
                                         backgroundColor: NSColor = NSColor.clear) -> NSImage
      {
        return fontAwesomeIcon(name: name,
                               style: style,
                               textColor: textColor,
                               size: CGSize(width: dimension, height: dimension),
                               backgroundColor: backgroundColor)
      }

      public static func fontAwesomeIcon(code: String,
                                         style: FontAwesomeStyle,
                                         textColor: NSColor,
                                         dimension: CGFloat,
                                         backgroundColor: NSColor = NSColor.clear) -> NSImage?
      {
        guard let name = String.fontAwesome(code: code) else { return nil }
        return fontAwesomeIcon(name: name,
                               style: style,
                               textColor: textColor,
                               dimension: dimension,
                               backgroundColor: backgroundColor)
      }

    /// Get a FontAwesome image with the given icon name, text color, size and an optional background color.
    ///
    /// - parameter name: The preferred icon name.
    /// - parameter style: The font style. Either .solid, .regular or .brands.
    /// - parameter textColor: The text color.
    /// - parameter size: The image size.
    /// - parameter backgroundColor: The background color (optional).
    /// - returns: A string that will appear as icon with FontAwesome
    public static func fontAwesomeIcon(name: FontAwesome, style: FontAwesomeStyle, textColor: NSColor, size: CGSize, backgroundColor: NSColor = NSColor.clear, borderWidth: CGFloat = 0, borderColor: NSColor = NSColor.clear) -> NSImage {

        // Prevent application crash when passing size where width or height is set equal to or less than zero, by clipping width and height to a minimum of 1 pixel.
        var size = size
        if size.width <= 0 { size.width = 1 }
        if size.height <= 0 { size.height = 1 }

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.center

        let fontSize = min(size.width / FontAwesomeConfig.fontAspectRatio, size.height)

        // stroke width expects a whole number percentage of the font size
        let strokeWidth: CGFloat = fontSize == 0 ? 0 : (-100 * borderWidth / fontSize)

        let attributedString = NSAttributedString(string: String.fontAwesomeIcon(name: name), attributes: [
            NSAttributedString.Key.font: NSFont.fontAwesome(ofSize: fontSize, style: style),
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.backgroundColor: backgroundColor,
            NSAttributedString.Key.paragraphStyle: paragraph,
            NSAttributedString.Key.strokeWidth: strokeWidth,
            NSAttributedString.Key.strokeColor: borderColor
            ])

        let image = NSImage(size: size)

        image.lockFocus()
        attributedString.draw(in: CGRect(x: 0, y: (size.height - fontSize) / 2, width: size.width, height: size.height))
        image.unlockFocus()

        let trimmedImage = image.trimming()!
        let trimmedSize = trimmedImage.size

        let result = NSImage(size: size)
        result.lockFocus()
        trimmedImage.draw(at: CGPoint(x: (size.width - trimmedSize.width) / 2, y: (size.height - trimmedSize.height) / 2),
                          from: .zero,
                          operation: .copy,
                          fraction:1)
        result.unlockFocus()

        return result
    }

    /// Get a FontAwesome image with the given icon css code, text color, size and an optional background color.
    ///
    /// - parameter code: The preferred icon css code.
    /// - parameter style: The font style. Either .solid, .regular or .brands.
    /// - parameter textColor: The text color.
    /// - parameter size: The image size.
    /// - parameter backgroundColor: The background color (optional).
    /// - returns: A string that will appear as icon with FontAwesome
    public static func fontAwesomeIcon(code: String, style: FontAwesomeStyle, textColor: NSColor, size: CGSize, backgroundColor: NSColor = NSColor.clear, borderWidth: CGFloat = 0, borderColor: NSColor = NSColor.clear) -> NSImage? {
        guard let name = String.fontAwesome(code: code) else { return nil }
        return fontAwesomeIcon(name: name, style: style, textColor: textColor, size: size, backgroundColor: backgroundColor, borderWidth: borderWidth, borderColor: borderColor)
    }
}

// MARK: - Private

private class FontLoader {
    class func loadFont(_ name: String) {
        guard
            let fontURL = URL.fontURL(for: name),
            let data = try? Data(contentsOf: fontURL),
            let provider = CGDataProvider(data: data as CFData),
            let font = CGFont(provider)
            else { return }

        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            let errorDescription: CFString = CFErrorCopyDescription(error!.takeUnretainedValue())
            guard let nsError = error?.takeUnretainedValue() as AnyObject as? NSError else { return }
            NSException(name: NSExceptionName.internalInconsistencyException, reason: errorDescription as String, userInfo: [NSUnderlyingErrorKey: nsError]).raise()
        }
    }
}

extension URL {
    static func fontURL(for fontName: String) -> URL? {
        let bundle = Bundle(for: FontLoader.self)

        if let fontURL = bundle.url(forResource: fontName, withExtension: "otf") {
            return fontURL
        }

        // If this framework is added using CocoaPods, resources is placed under a subdirectory
        if let fontURL = bundle.url(forResource: fontName, withExtension: "otf", subdirectory: "FontAwesome.swift.bundle") {
            return fontURL
        }

        return nil
    }
}

