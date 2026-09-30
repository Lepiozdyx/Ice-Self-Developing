import SwiftUI
import UIKit

enum Theme {
    static let background = Color(red: 0.043, green: 0.071, blue: 0.125)
    static let card = Color(red: 0.078, green: 0.118, blue: 0.196)
    static let cardRaised = Color(red: 0.102, green: 0.149, blue: 0.235)
    static let field = Color(red: 0.067, green: 0.102, blue: 0.176)
    static let accent = Color(red: 0.29, green: 0.565, blue: 0.996)
    static let accentDeep = Color(red: 0.176, green: 0.42, blue: 0.95)
    static let warmStart = Color(red: 1.0, green: 0.32, blue: 0.27)
    static let warmEnd = Color(red: 1.0, green: 0.55, blue: 0.28)
    static let ice = Color(red: 0.55, green: 0.78, blue: 0.98)
    static let secondaryText = Color(red: 0.62, green: 0.70, blue: 0.80)
    static let track = Color.white.opacity(0.12)
    static let border = Color.white.opacity(0.10)
    static let complete = Color(red: 0.29, green: 0.82, blue: 0.58)
    static let drift = Color(red: 0.45, green: 0.62, blue: 0.82)

    static let blueGradient = LinearGradient(
        colors: [accentDeep, accent, Color(red: 0.45, green: 0.72, blue: 1.0)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let warmGradient = LinearGradient(
        colors: [warmStart, warmEnd],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let corner: CGFloat = 22

    static func sphereColor(_ sphere: LifeSphere) -> Color {
        switch sphere {
        case .career: accent
        case .skills: warmEnd
        case .income: Color(red: 0.35, green: 0.82, blue: 0.86)
        case .health: complete
        case .relationships: Color(red: 0.67, green: 0.48, blue: 0.96)
        case .mindset: Color(red: 0.95, green: 0.38, blue: 0.42)
        case .environment: Color(red: 0.40, green: 0.78, blue: 0.62)
        }
    }
}

struct ScreenContainer<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            content
        }
    }
}

struct PrimaryButton: View {
    enum Style {
        case blue
        case warm
    }

    var title: String
    var systemImage: String?
    var style: Style = .blue
    var isEnabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.headline.weight(.semibold))
                }
            }
            .foregroundStyle(.white.opacity(isEnabled ? 1 : 0.55))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(background)
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityAddTraits(.isButton)
    }

    private var background: AnyShapeStyle {
        guard isEnabled else {
            return AnyShapeStyle(Theme.cardRaised)
        }
        switch style {
        case .blue: return AnyShapeStyle(Theme.blueGradient)
        case .warm: return AnyShapeStyle(Theme.warmGradient)
        }
    }
}

struct SurfaceCard<Content: View>: View {
    var padding: CGFloat = 16
    var stroke: Color = Theme.border
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.corner, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                    .stroke(stroke, lineWidth: 1)
            }
    }
}

struct SectionKicker: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .tracking(1.3)
            .foregroundStyle(Theme.secondaryText)
    }
}

struct LevelStepper: View {
    var value: Int
    var onChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 14) {
            stepButton(symbol: "minus", enabled: value > 1) {
                onChange(value - 1)
            }
            Text("\(value)")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(minWidth: 18)
            stepButton(symbol: "plus", enabled: value < 5) {
                onChange(value + 1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Level")
        .accessibilityValue("\(value)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment where value < 5: onChange(value + 1)
            case .decrement where value > 1: onChange(value - 1)
            default: break
            }
        }
    }

    private func stepButton(symbol: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(enabled ? 0.9 : 0.3))
                .frame(width: 32, height: 32)
                .background(Circle().fill(Theme.cardRaised))
                .overlay(Circle().stroke(Theme.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

struct LevelDots: View {
    var value: Int

    var body: some View {
        HStack(spacing: 5) {
            ForEach(1...5, id: \.self) { level in
                Circle()
                    .fill(level <= value ? Theme.accent : Theme.track)
                    .frame(width: 9, height: 9)
            }
        }
        .accessibilityLabel("Level \(value) of 5")
    }
}

struct MeterBar: View {
    var fraction: Double
    var tint: Color = Theme.warmEnd

    var body: some View {
        GeometryReader { geo in
            Capsule()
                .fill(Theme.track)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(tint)
                        .frame(width: max(0, geo.size.width * min(1, max(0, fraction))))
                }
        }
        .frame(height: 8)
    }
}

struct FilterChip: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? .white : Theme.secondaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    Capsule().fill(isSelected ? Theme.accent : Theme.card)
                }
                .overlay {
                    Capsule().stroke(isSelected ? Color.clear : Theme.border, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

struct PlusButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Theme.warmStart))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add")
    }
}

struct BackCircleButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Theme.cardRaised))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

struct IcebergMark: View {
    var melt: Double
    var warmth: Double

    var body: some View {
        let remaining = 1 - min(0.62, max(0, melt) * 0.55)
        IcebergShape()
            .fill(
                LinearGradient(
                    colors: [warmColor.opacity(0.95), Theme.ice.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 78, height: 92 * remaining)
            .shadow(color: warmColor.opacity(0.35), radius: 12, y: 4)
            .accessibilityHidden(true)
    }

    private var warmColor: Color {
        let warmth = min(1, max(0, warmth))
        return Color(
            red: 0.45 + 0.55 * warmth,
            green: 0.72 - 0.28 * warmth,
            blue: 0.95 - 0.55 * warmth
        )
    }
}

struct IcebergShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX * 0.92, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX * 0.15 + rect.width * 0.08, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct PageDots: View {
    var count: Int
    var index: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { item in
                Capsule()
                    .fill(item == index ? Theme.accent : Theme.track)
                    .frame(width: item == index ? 18 : 6, height: 6)
            }
        }
        .accessibilityLabel("Page \(index + 1) of \(count)")
    }
}

extension View {
    func keyboardDoneButton() -> some View {
        background(KeyboardDoneAccessory())
    }
}

struct FieldBox: View {
    var text: Binding<String>
    var placeholder: String
    var axis: Axis = .horizontal

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .foregroundStyle(Theme.secondaryText.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .allowsHitTesting(false)
            }
            if axis == .vertical {
                TextEditor(text: text)
                    .scrollContentBackground(.hidden)
                    .keyboardDoneButton()
                    .frame(minHeight: 96)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
            } else {
                TextField("", text: text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
            }
        }
        .foregroundStyle(.white)
        .background(Theme.field, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        }
    }
}

private struct KeyboardDoneAccessory: UIViewRepresentable {
    func makeUIView(context: Context) -> KeyboardDoneAnchor {
        let view = KeyboardDoneAnchor()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        view.isAccessibilityElement = false
        return view
    }

    func updateUIView(_ uiView: KeyboardDoneAnchor, context: Context) {
        uiView.installIfNeeded()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: KeyboardDoneAnchor, context: Context) -> CGSize? {
        .zero
    }
}

private final class KeyboardDoneAnchor: UIView {
    private weak var attachedInput: UIView?
    private var isInstalling = false

    override func didMoveToWindow() {
        super.didMoveToWindow()
        installIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        installIfNeeded()
    }

    func installIfNeeded() {
        guard attachedInput == nil, !isInstalling else { return }
        guard let input = enclosingTextInput() else { return }

        isInstalling = true
        defer { isInstalling = false }

        let toolbar = DoneKeyboardToolbar()
        let width = window?.bounds.width ?? input.bounds.width
        if width > 0 {
            toolbar.frame.size.width = width
        }
        if let textView = input as? UITextView {
            textView.inputAccessoryView = toolbar
            textView.reloadInputViews()
        } else if let textField = input as? UITextField {
            textField.inputAccessoryView = toolbar
            textField.reloadInputViews()
        }
        attachedInput = input
    }

    private func enclosingTextInput() -> UIView? {
        var node = superview
        var depth = 0
        while let current = node, depth < 12 {
            if current is UITextView || current is UITextField {
                return current
            }
            let matches = current.textInputs(maxDepth: 8)
            if matches.count == 1 {
                return matches[0]
            }
            if matches.count > 1, matches.allSatisfy({ $0.bounds.width > 0 }) {
                return closestTextInput(among: matches)
            }
            node = current.superview
            depth += 1
        }
        return nil
    }

    private func closestTextInput(among inputs: [UIView]) -> UIView? {
        let space = window ?? self
        let anchor = convert(bounds, to: space).center
        return inputs.min { lhs, rhs in
            let left = lhs.convert(lhs.bounds, to: space).center
            let right = rhs.convert(rhs.bounds, to: space).center
            let leftDistance = hypot(left.x - anchor.x, left.y - anchor.y)
            let rightDistance = hypot(right.x - anchor.x, right.y - anchor.y)
            return leftDistance < rightDistance
        }
    }
}

private extension UIView {
    func textInputs(maxDepth: Int) -> [UIView] {
        guard maxDepth > 0 else { return [] }
        var result: [UIView] = []
        for subview in subviews {
            if subview is UITextView || subview is UITextField {
                result.append(subview)
            } else if !(subview is KeyboardDoneAnchor) {
                result.append(contentsOf: subview.textInputs(maxDepth: maxDepth - 1))
            }
        }
        return result
    }
}

private extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

private final class DoneKeyboardToolbar: UIToolbar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        overrideUserInterfaceStyle = .dark
        tintColor = UIColor(Theme.accent)
        let done = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissKeyboard)
        )
        items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            done
        ]
        sizeToFit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
