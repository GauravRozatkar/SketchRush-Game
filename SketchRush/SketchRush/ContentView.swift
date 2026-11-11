//
//  ContentView.swift
//  SketchRush
//
//  Draw it. Guess it. Win it.
//  A pass-and-play drawing and guessing game for iPhone (SwiftUI, iOS 17 or later).
//
//  HOW TO USE:
//  1. Open ContentView.swift in your Xcode project.
//  2. Select everything (Cmd + A), delete it, and paste this whole file.
//  3. Leave your App file as it is. It already calls ContentView().
//  No other files and no extra permissions are needed.
//

import SwiftUI
import Combine
import UIKit

// MARK: - Theme

enum Palette {
    static let navy = Color(red: 0.07, green: 0.06, blue: 0.20)
    static let indigo = Color(red: 0.25, green: 0.14, blue: 0.62)
    static let purple = Color(red: 0.47, green: 0.27, blue: 0.98)
    static let pink = Color(red: 1.00, green: 0.31, blue: 0.56)
    static let orange = Color(red: 1.00, green: 0.58, blue: 0.20)
    static let yellow = Color(red: 1.00, green: 0.83, blue: 0.22)
    static let teal = Color(red: 0.10, green: 0.82, blue: 0.74)
    static let blue = Color(red: 0.25, green: 0.55, blue: 1.00)
}

enum Avatars {
    static let list = ["🦊", "🐼", "🐯", "🐸", "🐙", "🦄", "🐵", "🐧"]
}

enum Haptics {
    private static var isOn: Bool {
        UserDefaults.standard.object(forKey: "hapticsOn") as? Bool ?? true
    }

    static func tap() {
        guard isOn else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        guard isOn else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        guard isOn else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

// MARK: - Reusable UI pieces

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Palette.navy, Palette.indigo], startPoint: .top, endPoint: .bottom)
            Circle()
                .fill(Palette.pink.opacity(0.35))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: -140, y: -300)
            Circle()
                .fill(Palette.teal.opacity(0.28))
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .offset(x: 150, y: 330)
        }
        .ignoresSafeArea()
    }
}

struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var colors: [Color] = [Palette.yellow, Palette.orange]
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 18, weight: .heavy))
                }
                Text(title).font(.system(.headline, design: .rounded, weight: .heavy))
            }
            .foregroundStyle(Palette.navy)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing), in: Capsule())
            .shadow(color: colors[0].opacity(0.45), radius: 10, y: 5)
        }
        .buttonStyle(PressableStyle())
    }
}

struct GlassButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 16, weight: .bold))
                }
                Text(title).font(.system(.subheadline, design: .rounded, weight: .bold))
            }
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.16), in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
        }
        .buttonStyle(PressableStyle())
    }
}

struct CircleIconButton: View {
    let system: String
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Image(systemName: system)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.15), in: Circle())
        }
        .buttonStyle(PressableStyle())
    }
}

struct ScreenHeader: View {
    let title: String
    let onBack: () -> Void
    var trailingIcon: String? = nil
    var onTrailing: (() -> Void)? = nil

    var body: some View {
        HStack {
            CircleIconButton(system: "chevron.left", action: onBack)
            Spacer()
            Text(title)
                .font(.system(.title3, design: .rounded, weight: .heavy))
                .foregroundStyle(Color.white)
            Spacer()
            if let trailingIcon, let onTrailing {
                CircleIconButton(system: trailingIcon, action: onTrailing)
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct BigButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let colors: [Color]
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .bold))
                    .frame(width: 52, height: 52)
                    .background(Color.white.opacity(0.22), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(.title3, design: .rounded, weight: .heavy))
                    Text(subtitle)
                        .font(.system(.footnote, design: .rounded, weight: .medium))
                        .opacity(0.85)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.headline.weight(.bold))
                    .opacity(0.7)
            }
            .foregroundStyle(Color.white)
            .padding(14)
            .background(
                LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .shadow(color: colors[0].opacity(0.45), radius: 12, y: 6)
        }
        .buttonStyle(PressableStyle())
    }
}

struct ChipPicker<T: Hashable>: View {
    let options: [T]
    @Binding var selection: T
    let label: (T) -> String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button {
                    Haptics.tap()
                    selection = option
                } label: {
                    Text(label(option))
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(selection == option ? Palette.navy : Color.white)
                        .background(
                            selection == option ? Color.white : Color.white.opacity(0.14),
                            in: Capsule()
                        )
                }
                .buttonStyle(PressableStyle())
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Drawing engine

struct InkStroke: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var width: CGFloat
}

final class DrawingBoard: ObservableObject {
    static let colors: [Color] = [
        Color.black,
        Color(white: 0.45),
        Color(red: 0.93, green: 0.18, blue: 0.20),
        Color(red: 1.00, green: 0.55, blue: 0.10),
        Color(red: 1.00, green: 0.82, blue: 0.10),
        Color(red: 0.20, green: 0.75, blue: 0.30),
        Color(red: 0.10, green: 0.78, blue: 0.72),
        Color(red: 0.15, green: 0.45, blue: 0.95),
        Color(red: 0.45, green: 0.25, blue: 0.85),
        Color(red: 1.00, green: 0.35, blue: 0.65),
        Color(red: 0.48, green: 0.30, blue: 0.16)
    ]
    static let sizes: [CGFloat] = [4, 9, 16, 26]

    @Published var strokes: [InkStroke] = []
    @Published var redoStack: [InkStroke] = []
    @Published var current: InkStroke? = nil
    @Published var colorIndex = 0
    @Published var sizeIndex = 1
    @Published var isEraser = false

    /// Size of the canvas on screen, used for previews and sharing.
    var canvasSize: CGSize = .zero

    func begin(at point: CGPoint) {
        let base = Self.sizes[sizeIndex]
        current = InkStroke(
            points: [point],
            color: isEraser ? Color.white : Self.colors[colorIndex],
            width: isEraser ? base * 2 : base
        )
    }

    func append(_ point: CGPoint) {
        guard let last = current?.points.last else { return }
        if hypot(last.x - point.x, last.y - point.y) < 1.0 { return }
        current?.points.append(point)
    }

    func end() {
        if let stroke = current {
            strokes.append(stroke)
            redoStack.removeAll()
        }
        current = nil
    }

    func undo() {
        guard let last = strokes.popLast() else { return }
        redoStack.append(last)
    }

    func redo() {
        guard let last = redoStack.popLast() else { return }
        strokes.append(last)
    }

    func clear() {
        strokes.removeAll()
        redoStack.removeAll()
        current = nil
    }
}

enum StrokeRenderer {
    /// Draws one stroke inside a SwiftUI Canvas.
    static func draw(_ stroke: InkStroke, in context: GraphicsContext) {
        guard let first = stroke.points.first else { return }
        if stroke.points.count == 1 {
            let r = stroke.width / 2
            let dot = Path(ellipseIn: CGRect(x: first.x - r, y: first.y - r, width: stroke.width, height: stroke.width))
            context.fill(dot, with: .color(stroke.color))
            return
        }
        let pts = stroke.points
        var path = Path()
        path.move(to: first)
        if pts.count == 2 {
            path.addLine(to: pts[1])
        } else {
            for i in 1..<(pts.count - 1) {
                let mid = CGPoint(x: (pts[i].x + pts[i + 1].x) / 2, y: (pts[i].y + pts[i + 1].y) / 2)
                path.addQuadCurve(to: mid, control: pts[i])
            }
            path.addLine(to: pts[pts.count - 1])
        }
        context.stroke(
            path,
            with: .color(stroke.color),
            style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round)
        )
    }

    /// Renders strokes to a UIImage (white paper) for sharing.
    static func image(strokes: [InkStroke], size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 3
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            let cg = ctx.cgContext
            cg.setLineCap(.round)
            cg.setLineJoin(.round)
            for stroke in strokes {
                guard let first = stroke.points.first else { continue }
                let color = UIColor(stroke.color).cgColor
                if stroke.points.count == 1 {
                    cg.setFillColor(color)
                    cg.fillEllipse(in: CGRect(
                        x: first.x - stroke.width / 2,
                        y: first.y - stroke.width / 2,
                        width: stroke.width,
                        height: stroke.width
                    ))
                    continue
                }
                cg.setStrokeColor(color)
                cg.setLineWidth(stroke.width)
                cg.beginPath()
                cg.move(to: first)
                let pts = stroke.points
                if pts.count == 2 {
                    cg.addLine(to: pts[1])
                } else {
                    for i in 1..<(pts.count - 1) {
                        let mid = CGPoint(x: (pts[i].x + pts[i + 1].x) / 2, y: (pts[i].y + pts[i + 1].y) / 2)
                        cg.addQuadCurve(to: mid, control: pts[i])
                    }
                    cg.addLine(to: pts[pts.count - 1])
                }
                cg.strokePath()
            }
        }
    }
}

struct DrawingCanvas: View {
    @ObservedObject var board: DrawingBoard

    var body: some View {
        GeometryReader { geo in
            Canvas { context, _ in
                for stroke in board.strokes {
                    StrokeRenderer.draw(stroke, in: context)
                }
                if let current = board.current {
                    StrokeRenderer.draw(current, in: context)
                }
            }
            .background(Color.white)
            .contentShape(Rectangle())
            .gesture(drawGesture)
            .onAppear { board.canvasSize = geo.size }
            .onChange(of: geo.size) { _, newSize in
                board.canvasSize = newSize
            }
        }
    }

    private var drawGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if board.current == nil {
                    board.begin(at: value.startLocation)
                }
                board.append(value.location)
            }
            .onEnded { value in
                board.append(value.location)
                board.end()
            }
    }
}

struct DrawingPreview: View {
    let strokes: [InkStroke]
    let reference: CGSize

    var body: some View {
        let ratio = reference.height > 0 ? reference.width / reference.height : 1
        Canvas { context, size in
            let scale = reference.width > 0 ? size.width / reference.width : 1
            context.scaleBy(x: scale, y: scale)
            for stroke in strokes {
                StrokeRenderer.draw(stroke, in: context)
            }
        }
        .aspectRatio(ratio, contentMode: .fit)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct ToolIcon: View {
    let system: String
    var active = false
    var enabled = true
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Image(systemName: system)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(active ? Palette.navy : Color.white)
                .frame(width: 34, height: 36)
                .background(
                    active ? Color.white : Color.white.opacity(0.14),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
                .opacity(enabled ? 1 : 0.35)
        }
        .disabled(!enabled)
        .buttonStyle(PressableStyle())
    }
}

struct ToolTray: View {
    @ObservedObject var board: DrawingBoard
    @State private var confirmClear = false

    var body: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(DrawingBoard.colors.indices, id: \.self) { i in
                        let selected = !board.isEraser && board.colorIndex == i
                        Circle()
                            .fill(DrawingBoard.colors[i])
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle().stroke(
                                    selected ? Color.white : Color.white.opacity(0.5),
                                    lineWidth: selected ? 3.5 : 1
                                )
                            )
                            .scaleEffect(selected ? 1.12 : 1)
                            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: selected)
                            .onTapGesture {
                                Haptics.tap()
                                board.colorIndex = i
                                board.isEraser = false
                            }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
            }

            HStack(spacing: 5) {
                ForEach(DrawingBoard.sizes.indices, id: \.self) { i in
                    let active = board.sizeIndex == i
                    let dot = 4 + DrawingBoard.sizes[i] * 0.6
                    Button {
                        Haptics.tap()
                        board.sizeIndex = i
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(active ? Color.white : Color.white.opacity(0.14))
                            Circle()
                                .fill(active ? Palette.navy : Color.white)
                                .frame(width: dot, height: dot)
                        }
                        .frame(width: 32, height: 36)
                    }
                    .buttonStyle(PressableStyle())
                }

                Spacer(minLength: 0)

                ToolIcon(system: "pencil", active: !board.isEraser) { board.isEraser = false }
                ToolIcon(system: "eraser.fill", active: board.isEraser) { board.isEraser = true }
                ToolIcon(system: "arrow.uturn.backward", enabled: !board.strokes.isEmpty) { board.undo() }
                ToolIcon(system: "arrow.uturn.forward", enabled: !board.redoStack.isEmpty) { board.redo() }
                ToolIcon(system: "trash", enabled: !board.strokes.isEmpty) { confirmClear = true }
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .alert("Clear the canvas?", isPresented: $confirmClear) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) { board.clear() }
        }
    }
}

// MARK: - Words

enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case mixed = "Mixed"

    var id: String { rawValue }
}

enum WordBank {
    static let easy: [String] = [
        "Cat", "Dog", "Sun", "Moon", "Tree", "House", "Car", "Pizza", "Apple", "Banana",
        "Fish", "Bird", "Flower", "Star", "Heart", "Ball", "Book", "Chair", "Cake", "Cup",
        "Hat", "Shoe", "Key", "Clock", "Rain", "Cloud", "Snowman", "Smile", "Bed", "Door",
        "Boat", "Train", "Bike", "Egg", "Ice cream", "Balloon", "Umbrella", "Candle", "Phone",
        "Guitar", "Spider", "Butterfly", "Rabbit", "Duck", "Cow", "Pig", "Horse", "Lion",
        "Elephant", "Mountain", "Beach", "Bridge", "Tooth", "Eye", "Hand", "Crown", "Rocket",
        "Robot", "Ghost", "Rainbow"
    ]

    static let medium: [String] = [
        "Astronaut", "Pirate", "Dragon", "Volcano", "Lighthouse", "Skateboard", "Headphones",
        "Camera", "Fireworks", "Cactus", "Penguin", "Octopus", "Wizard", "Mermaid", "Treasure map",
        "Hot air balloon", "Roller coaster", "Snowboard", "Sandcastle", "Campfire", "Windmill",
        "Submarine", "Tractor", "Helicopter", "Jellyfish", "Kangaroo", "Giraffe", "Popcorn",
        "Hamburger", "Sunglasses", "Backpack", "Magnet", "Telescope", "Scarecrow", "Vampire",
        "Unicorn", "Traffic light", "Birthday party", "Swimming pool", "Shopping cart",
        "Fishing rod", "Bowling", "Lightning", "Tornado", "Piano", "Drum", "Pancake", "Sushi",
        "Cricket bat", "Chess board"
    ]

    static let hard: [String] = [
        "Democracy", "Gravity", "Jealousy", "Time travel", "Earthquake", "Traffic jam",
        "Black hole", "Karaoke", "Marathon", "Passport", "Skyscraper", "Meditation",
        "Photosynthesis", "Invisible", "Procrastination", "Allergy", "Echo", "Mirage", "Tsunami",
        "Detective", "Sleepwalking", "Superhero", "Rush hour", "Wi-Fi", "Selfie", "Homesick",
        "Jet lag", "Bargain", "Applause", "Daydream", "Eclipse", "Avalanche", "Archaeologist",
        "Hypnosis", "Origami", "Quicksand", "Pickpocket", "Stage fright", "Deja vu", "Cryptocurrency"
    ]

    static var all: [String] { easy + medium + hard }

    static func choices(for difficulty: Difficulty) -> [String] {
        switch difficulty {
        case .easy:
            return Array(easy.shuffled().prefix(3))
        case .medium:
            return Array(medium.shuffled().prefix(3))
        case .hard:
            return Array(hard.shuffled().prefix(3))
        case .mixed:
            return [easy.randomElement() ?? "Cat", medium.randomElement() ?? "Pirate", hard.randomElement() ?? "Gravity"]
        }
    }

    static func multiplier(for word: String) -> Double {
        if hard.contains(word) { return 2.0 }
        if medium.contains(word) { return 1.5 }
        return 1.0
    }

    static func tag(for word: String) -> (text: String, color: Color) {
        if hard.contains(word) { return ("Hard  x2", Palette.pink) }
        if medium.contains(word) { return ("Medium  x1.5", Palette.orange) }
        return ("Easy  x1", Palette.teal)
    }
}

// MARK: - Game model

struct Player: Identifiable {
    let id = UUID()
    var name: String
    var emoji: String
    var score = 0
}

struct GameConfig {
    var names: [String]
    var rounds: Int
    var seconds: Int
    var difficulty: Difficulty
}

enum TurnPhase {
    case handoff
    case pickWord
    case drawing
    case whoGuessed
    case result
    case finished
}

final class GameEngine: ObservableObject {
    @Published var players: [Player]
    @Published var phase: TurnPhase = .handoff
    @Published var turn = 0
    @Published var timeLeft: Int
    @Published var choices: [String] = []
    @Published var word = ""
    @Published var showWord = false
    @Published var resultTitle = ""
    @Published var resultDetail = ""

    let config: GameConfig
    let board = DrawingBoard()
    private var revealOrder: [Int] = []

    init(config: GameConfig) {
        self.config = config
        var list: [Player] = []
        for (i, name) in config.names.enumerated() {
            let clean = name.isEmpty ? "Player \(i + 1)" : name
            list.append(Player(name: clean, emoji: Avatars.list[i % Avatars.list.count]))
        }
        self.players = list
        self.timeLeft = config.seconds
    }

    // MARK: Derived values

    var totalTurns: Int { config.rounds * players.count }
    var drawerIndex: Int { turn % players.count }
    var drawer: Player { players[drawerIndex] }
    var round: Int { turn / players.count + 1 }
    var isLastTurn: Bool { turn + 1 >= totalTurns }
    var guessers: [Player] { players.filter { $0.id != drawer.id } }
    var ranking: [Player] { players.sorted { $0.score > $1.score } }

    var winnerTitle: String {
        let top = players.map { $0.score }.max() ?? 0
        let winners = players.filter { $0.score == top }
        if winners.count == 1 { return "\(winners[0].name) wins!" }
        return "It's a tie!"
    }

    /// Hint like "_ _ A _ _". Letters are revealed as time runs down.
    var hint: String {
        let fraction = Double(timeLeft) / Double(max(config.seconds, 1))
        var reveal = 0
        if fraction <= 0.25 {
            reveal = 2
        } else if fraction <= 0.5 {
            reveal = 1
        }
        reveal = min(reveal, max(revealOrder.count - 2, 0))
        let revealed = Set(revealOrder.prefix(reveal))
        var parts: [String] = []
        for (i, ch) in word.enumerated() {
            if ch == " " {
                parts.append("  ")
            } else if revealed.contains(i) {
                parts.append(String(ch).uppercased())
            } else {
                parts.append("_")
            }
        }
        return parts.joined(separator: " ")
    }

    // MARK: Turn flow

    func beginTurn() {
        choices = WordBank.choices(for: config.difficulty)
        phase = .pickWord
    }

    func rerollChoices() {
        choices = WordBank.choices(for: config.difficulty)
    }

    func choose(_ chosen: String) {
        word = chosen
        var indexes: [Int] = []
        for (i, ch) in chosen.enumerated() where ch != " " {
            indexes.append(i)
        }
        revealOrder = indexes.shuffled()
        board.clear()
        timeLeft = config.seconds
        showWord = false
        phase = .drawing
    }

    func tick() {
        guard phase == .drawing else { return }
        if timeLeft > 0 {
            timeLeft -= 1
            if timeLeft > 0 && timeLeft <= 5 { Haptics.tap() }
        }
        if timeLeft == 0 {
            Haptics.warning()
            phase = .whoGuessed
        }
    }

    func resumeDrawing() {
        guard timeLeft > 0 else { return }
        phase = .drawing
    }

    func openGuessPicker() {
        phase = .whoGuessed
    }

    func playerGuessed(_ guesser: Player) {
        let ratio = Double(timeLeft) / Double(max(config.seconds, 1))
        let multiplier = WordBank.multiplier(for: word)
        let guesserPoints = Int((50 + ratio * 50) * multiplier)
        let drawerPoints = Int(40 * multiplier)
        if let gi = players.firstIndex(where: { $0.id == guesser.id }) {
            players[gi].score += guesserPoints
        }
        players[drawerIndex].score += drawerPoints
        resultTitle = "\(guesser.name) got it!"
        resultDetail = "\(guesser.name) +\(guesserPoints) pts and \(drawer.name) +\(drawerPoints) pts"
        Haptics.success()
        phase = .result
    }

    func nobodyGuessed() {
        resultTitle = "Nobody got it"
        resultDetail = "No points this turn"
        phase = .result
    }

    func nextTurn() {
        turn += 1
        if turn >= totalTurns {
            finish()
        } else {
            phase = .handoff
        }
    }

    private func finish() {
        let defaults = UserDefaults.standard
        defaults.set(defaults.integer(forKey: "gamesPlayed") + 1, forKey: "gamesPlayed")
        let top = players.map { $0.score }.max() ?? 0
        if top > defaults.integer(forKey: "highScore") {
            defaults.set(top, forKey: "highScore")
        }
        phase = .finished
    }

    func restart() {
        for i in players.indices { players[i].score = 0 }
        turn = 0
        word = ""
        board.clear()
        phase = .handoff
    }
}

// MARK: - Root

enum Route {
    case home
    case setup
    case game
    case free
    case howTo
}

struct ContentView: View {
    @State private var route: Route = .home
    @State private var engine: GameEngine? = nil

    var body: some View {
        ZStack {
            AppBackground()
            switch route {
            case .home:
                HomeView(
                    onPlay: { go(.setup) },
                    onFree: { go(.free) },
                    onHow: { go(.howTo) }
                )
            case .setup:
                SetupView(
                    onBack: { go(.home) },
                    onStart: { config in
                        engine = GameEngine(config: config)
                        go(.game)
                    }
                )
            case .game:
                if let engine {
                    GameView(engine: engine, onExit: { go(.home) })
                }
            case .free:
                FreeDrawView(onBack: { go(.home) })
            case .howTo:
                HowToView(onBack: { go(.home) })
            }
        }
        .preferredColorScheme(.dark)
    }

    private func go(_ next: Route) {
        withAnimation(.easeInOut(duration: 0.3)) {
            route = next
        }
    }
}

// MARK: - Home

struct HomeView: View {
    var onPlay: () -> Void
    var onFree: () -> Void
    var onHow: () -> Void

    @AppStorage("gamesPlayed") private var gamesPlayed = 0
    @AppStorage("highScore") private var highScore = 0
    @State private var bob = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                logo
                VStack(spacing: 14) {
                    BigButton(
                        title: "Play with Friends",
                        subtitle: "2 to 8 players, one phone",
                        icon: "person.3.fill",
                        colors: [Palette.pink, Palette.orange],
                        action: onPlay
                    )
                    BigButton(
                        title: "Free Draw",
                        subtitle: "Doodle, get ideas, share your art",
                        icon: "paintbrush.pointed.fill",
                        colors: [Palette.teal, Palette.blue],
                        action: onFree
                    )
                    BigButton(
                        title: "How to Play",
                        subtitle: "Learn the rules in 30 seconds",
                        icon: "questionmark.circle.fill",
                        colors: [Palette.purple, Palette.indigo],
                        action: onHow
                    )
                }
                statsCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
        .onAppear { bob = true }
    }

    private var logo: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.pink, Palette.orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 128, height: 128)
                    .shadow(color: Palette.pink.opacity(0.5), radius: 20, y: 10)
                Image(systemName: "pencil.and.scribble")
                    .font(.system(size: 62, weight: .heavy))
                    .foregroundStyle(Color.white)
            }
            .rotationEffect(.degrees(bob ? 4 : -4))
            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: bob)

            Text("SketchRush")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundStyle(Color.white)
            Text("Draw it. Guess it. Win it.")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.75))
        }
    }

    private var statsCard: some View {
        HStack {
            stat(value: "\(gamesPlayed)", label: "Games played")
            Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1, height: 36)
            stat(value: "\(highScore)", label: "Best score")
        }
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func stat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(Palette.yellow)
            Text(label)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Setup

struct PlayerEntry: Identifiable {
    let id = UUID()
    var name = ""
}

struct SetupView: View {
    var onBack: () -> Void
    var onStart: (GameConfig) -> Void

    @State private var entries: [PlayerEntry] = [PlayerEntry(), PlayerEntry()]
    @State private var rounds = 2
    @State private var seconds = 60
    @State private var difficulty: Difficulty = .mixed

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "Game Setup", onBack: onBack)

            ScrollView {
                VStack(spacing: 16) {
                    card(title: "Players") {
                        VStack(spacing: 10) {
                            ForEach($entries) { $entry in
                                HStack(spacing: 10) {
                                    Text(avatar(for: entry.id)).font(.title2)
                                    TextField(
                                        "",
                                        text: $entry.name,
                                        prompt: Text(placeholder(for: entry.id)).foregroundStyle(Color.white.opacity(0.45))
                                    )
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled()
                                    .submitLabel(.done)
                                    .foregroundStyle(Color.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                                    if entries.count > 2 {
                                        Button {
                                            Haptics.tap()
                                            let removeID = entry.id
                                            entries.removeAll { $0.id == removeID }
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.title3)
                                                .foregroundStyle(Palette.pink)
                                        }
                                    }
                                }
                            }

                            if entries.count < 8 {
                                Button {
                                    Haptics.tap()
                                    entries.append(PlayerEntry())
                                } label: {
                                    Label("Add player", systemImage: "plus.circle.fill")
                                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                                        .foregroundStyle(Palette.teal)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                    }

                    card(title: "Rounds") {
                        ChipPicker(options: [1, 2, 3, 4], selection: $rounds) { "\($0)" }
                    }

                    card(title: "Drawing time") {
                        ChipPicker(options: [30, 60, 90, 120], selection: $seconds) { "\($0)s" }
                    }

                    card(title: "Difficulty") {
                        ChipPicker(options: Difficulty.allCases, selection: $difficulty) { $0.rawValue }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.interactively)

            PrimaryButton(title: "Start game", icon: "play.fill") { start() }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .padding(.top, 4)
        }
    }

    private func card<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(.caption, design: .rounded, weight: .heavy))
                .foregroundStyle(Color.white.opacity(0.6))
                .tracking(1.2)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func index(of id: UUID) -> Int {
        entries.firstIndex { $0.id == id } ?? 0
    }

    private func avatar(for id: UUID) -> String {
        Avatars.list[index(of: id) % Avatars.list.count]
    }

    private func placeholder(for id: UUID) -> String {
        "Player \(index(of: id) + 1)"
    }

    private func start() {
        let names = entries.map { $0.name.trimmingCharacters(in: .whitespacesAndNewlines) }
        onStart(GameConfig(names: names, rounds: rounds, seconds: seconds, difficulty: difficulty))
    }
}

// MARK: - Game screens

struct GameView: View {
    @ObservedObject var engine: GameEngine
    var onExit: () -> Void

    @State private var confirmExit = false
    @State private var showScores = false
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            header
            ZStack {
                Group {
                    switch engine.phase {
                    case .handoff:
                        HandoffView(engine: engine)
                    case .pickWord:
                        PickWordView(engine: engine)
                    case .drawing:
                        DrawingPhaseView(engine: engine)
                    case .whoGuessed:
                        WhoGuessedView(engine: engine)
                    case .result:
                        ResultView(engine: engine)
                    case .finished:
                        FinishedView(engine: engine, onMenu: onExit)
                    }
                }
                .transition(.opacity)
            }
            .animation(.easeInOut(duration: 0.25), value: engine.phase)
        }
        .onReceive(ticker) { _ in engine.tick() }
        .alert("Quit this game?", isPresented: $confirmExit) {
            Button("Keep playing", role: .cancel) {}
            Button("Quit", role: .destructive) { onExit() }
        } message: {
            Text("Your scores will be lost.")
        }
        .sheet(isPresented: $showScores) {
            ScoreboardSheet(players: engine.ranking)
        }
    }

    private var header: some View {
        HStack {
            CircleIconButton(system: "xmark") { confirmExit = true }
            Spacer()
            if engine.phase != .finished {
                Text("Round \(min(engine.round, engine.config.rounds)) of \(engine.config.rounds)")
                    .font(.system(.subheadline, design: .rounded, weight: .heavy))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.15), in: Capsule())
            }
            Spacer()
            CircleIconButton(system: "list.number") { showScores = true }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct HandoffView: View {
    @ObservedObject var engine: GameEngine

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Text(engine.drawer.emoji).font(.system(size: 100))
            Text("\(engine.drawer.name)'s turn to draw")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(Color.white)
                .multilineTextAlignment(.center)
            Text("Pass the phone to \(engine.drawer.name). Everyone else, look away while the word is picked.")
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.75))
                .multilineTextAlignment(.center)
            Spacer()
            PrimaryButton(title: "I'm ready", icon: "hand.thumbsup.fill") { engine.beginTurn() }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 20)
    }
}

struct PickWordView: View {
    @ObservedObject var engine: GameEngine

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Text("\(engine.drawer.emoji) \(engine.drawer.name)")
                .font(.system(.title2, design: .rounded, weight: .heavy))
                .foregroundStyle(Color.white.opacity(0.85))
            Text("Pick a word to draw")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(Color.white)

            VStack(spacing: 12) {
                ForEach(engine.choices, id: \.self) { choice in
                    let tag = WordBank.tag(for: choice)
                    Button {
                        Haptics.tap()
                        engine.choose(choice)
                    } label: {
                        VStack(spacing: 8) {
                            Text(choice)
                                .font(.system(.title2, design: .rounded, weight: .heavy))
                                .foregroundStyle(Palette.navy)
                            Text(tag.text)
                                .font(.system(.caption, design: .rounded, weight: .heavy))
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(tag.color, in: Capsule())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: Color.black.opacity(0.25), radius: 8, y: 4)
                    }
                    .buttonStyle(PressableStyle())
                }
            }

            GlassButton(title: "Show me different words", icon: "dice.fill") { engine.rerollChoices() }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
}

struct TimerBar: View {
    let timeLeft: Int
    let total: Int

    var body: some View {
        let fraction = Double(timeLeft) / Double(max(total, 1))
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.18))
                Capsule()
                    .fill(fraction > 0.5 ? Palette.teal : (fraction > 0.25 ? Palette.yellow : Palette.pink))
                    .frame(width: geo.size.width * fraction)
                    .animation(.linear(duration: 1), value: timeLeft)
            }
        }
        .frame(height: 10)
    }
}

struct DrawingPhaseView: View {
    @ObservedObject var engine: GameEngine

    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 6) {
                HStack {
                    Text("\(engine.drawer.emoji) \(engine.drawer.name) is drawing")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.8))
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                        Text("\(engine.timeLeft)s").monospacedDigit()
                    }
                    .font(.system(.subheadline, design: .rounded, weight: .heavy))
                    .foregroundStyle(engine.timeLeft <= 10 ? Palette.pink : Color.white)
                }
                Text(engine.showWord ? engine.word.uppercased() : engine.hint)
                    .font(.system(.title3, design: .monospaced, weight: .heavy))
                    .foregroundStyle(Palette.yellow)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity)
                TimerBar(timeLeft: engine.timeLeft, total: engine.config.seconds)
            }
            .padding(.horizontal, 16)

            DrawingCanvas(board: engine.board)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: Color.black.opacity(0.3), radius: 10, y: 5)
                .padding(.horizontal, 10)

            ToolTray(board: engine.board)
                .padding(.horizontal, 10)

            HStack(spacing: 10) {
                GlassButton(
                    title: engine.showWord ? "Hide word" : "Peek word",
                    icon: engine.showWord ? "eye.slash.fill" : "eye.fill"
                ) {
                    engine.showWord.toggle()
                }
                PrimaryButton(title: "Guessed it!", icon: "checkmark.circle.fill", colors: [Palette.teal, Palette.blue]) {
                    engine.openGuessPicker()
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        }
    }
}

struct WhoGuessedView: View {
    @ObservedObject var engine: GameEngine

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text(engine.timeLeft == 0 ? "Time is up!" : "Nice one!")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(Color.white)
                    .padding(.top, 20)
                Text("Who guessed it?")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.75))
                    .padding(.bottom, 6)

                ForEach(engine.guessers) { player in
                    Button {
                        engine.playerGuessed(player)
                    } label: {
                        HStack(spacing: 12) {
                            Text(player.emoji).font(.system(size: 34))
                            Text(player.name)
                                .font(.system(.title3, design: .rounded, weight: .heavy))
                                .foregroundStyle(Palette.navy)
                            Spacer()
                            Text("\(player.score) pts")
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(Palette.navy.opacity(0.6))
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(PressableStyle())
                }

                GlassButton(title: "Nobody guessed it", icon: "xmark") { engine.nobodyGuessed() }
                    .padding(.top, 6)

                if engine.timeLeft > 0 {
                    GlassButton(title: "Keep drawing", icon: "pencil") { engine.resumeDrawing() }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }
}

struct ResultView: View {
    @ObservedObject var engine: GameEngine
    @State private var shareImage: UIImage? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text("The word was")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .padding(.top, 8)
                Text(engine.word.uppercased())
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(Palette.yellow)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)

                DrawingPreview(strokes: engine.board.strokes, reference: engine.board.canvasSize)
                    .frame(maxHeight: 300)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, y: 5)

                Text(engine.resultTitle)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                Text(engine.resultDetail)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.75))
                    .multilineTextAlignment(.center)

                HStack(spacing: 10) {
                    GlassButton(title: "Share", icon: "square.and.arrow.up") { share() }
                    PrimaryButton(
                        title: engine.isLastTurn ? "Final scores" : "Next turn",
                        icon: "arrow.right"
                    ) {
                        engine.nextTurn()
                    }
                }
                .padding(.top, 6)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: Binding(
            get: { shareImage != nil },
            set: { if !$0 { shareImage = nil } }
        )) {
            if let shareImage {
                ShareSheet(items: [shareImage])
            }
        }
    }

    private func share() {
        let size = engine.board.canvasSize
        guard size.width > 0, size.height > 0 else { return }
        shareImage = StrokeRenderer.image(strokes: engine.board.strokes, size: size)
    }
}

struct ScoreRow: View {
    let rank: Int
    let player: Player

    private var medal: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(medal)
                .font(.system(size: 26))
                .frame(width: 40)
            Text(player.emoji).font(.system(size: 30))
            Text(player.name)
                .font(.system(.title3, design: .rounded, weight: .heavy))
                .foregroundStyle(Color.white)
                .lineLimit(1)
            Spacer()
            Text("\(player.score)")
                .font(.system(.title2, design: .rounded, weight: .black))
                .foregroundStyle(Palette.yellow)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct ScoreboardSheet: View {
    let players: [Player]

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 10) {
                    Text("Scoreboard")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white)
                        .padding(.top, 24)
                        .padding(.bottom, 6)
                    ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                        ScoreRow(rank: index + 1, player: player)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct ConfettiView: View {
    struct Piece: Identifiable {
        let id = UUID()
        let x: CGFloat
        let size: CGFloat
        let duration: Double
        let delay: Double
        let symbol: String
    }

    @State private var fall = false
    private let pieces: [Piece] = (0..<26).map { _ in
        Piece(
            x: CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 18...34),
            duration: Double.random(in: 3...6),
            delay: Double.random(in: 0...3),
            symbol: ["🎉", "⭐️", "✨", "🎊", "🏆"].randomElement() ?? "🎉"
        )
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(pieces) { piece in
                Text(piece.symbol)
                    .font(.system(size: piece.size))
                    .position(x: piece.x * geo.size.width, y: fall ? geo.size.height + 60 : -60)
                    .animation(
                        .linear(duration: piece.duration).delay(piece.delay).repeatForever(autoreverses: false),
                        value: fall
                    )
            }
        }
        .allowsHitTesting(false)
        .onAppear { fall = true }
    }
}

struct FinishedView: View {
    @ObservedObject var engine: GameEngine
    var onMenu: () -> Void

    var body: some View {
        ZStack {
            ConfettiView()
            ScrollView {
                VStack(spacing: 14) {
                    Text("🏆").font(.system(size: 84)).padding(.top, 10)
                    Text(engine.winnerTitle)
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                    Text("Final scores")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .padding(.bottom, 4)

                    ForEach(Array(engine.ranking.enumerated()), id: \.element.id) { index, player in
                        ScoreRow(rank: index + 1, player: player)
                    }

                    PrimaryButton(title: "Play again", icon: "arrow.clockwise") { engine.restart() }
                        .padding(.top, 10)
                    GlassButton(title: "Main menu", icon: "house.fill") { onMenu() }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear { Haptics.success() }
    }
}

// MARK: - Free draw

struct FreeDrawView: View {
    var onBack: () -> Void

    @StateObject private var board = DrawingBoard()
    @State private var prompt: String? = nil
    @State private var shareImage: UIImage? = nil

    var body: some View {
        VStack(spacing: 10) {
            ScreenHeader(
                title: "Free Draw",
                onBack: onBack,
                trailingIcon: "square.and.arrow.up",
                onTrailing: { share() }
            )

            HStack(spacing: 10) {
                Button {
                    Haptics.tap()
                    prompt = WordBank.all.randomElement()
                } label: {
                    Label("Idea", systemImage: "dice.fill")
                        .font(.system(.subheadline, design: .rounded, weight: .heavy))
                        .foregroundStyle(Palette.navy)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Palette.yellow, in: Capsule())
                }
                .buttonStyle(PressableStyle())

                Text(prompt.map { "Draw: \($0)" } ?? "Tap Idea for something to draw")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)

            DrawingCanvas(board: board)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: Color.black.opacity(0.3), radius: 10, y: 5)
                .padding(.horizontal, 10)

            ToolTray(board: board)
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
        }
        .sheet(isPresented: Binding(
            get: { shareImage != nil },
            set: { if !$0 { shareImage = nil } }
        )) {
            if let shareImage {
                ShareSheet(items: [shareImage])
            }
        }
    }

    private func share() {
        let size = board.canvasSize
        guard size.width > 0, size.height > 0, !board.strokes.isEmpty else {
            Haptics.warning()
            return
        }
        shareImage = StrokeRenderer.image(strokes: board.strokes, size: size)
    }
}

// MARK: - How to play

struct HowStep: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let text: String
}

struct HowToView: View {
    var onBack: () -> Void
    @AppStorage("hapticsOn") private var hapticsOn = true

    private let steps: [HowStep] = [
        HowStep(icon: "person.3.fill", title: "Add your players",
                text: "2 to 8 friends share one iPhone. Choose rounds, drawing time and difficulty."),
        HowStep(icon: "hand.raised.fill", title: "Pass the phone",
                text: "The drawer picks one of three secret words. Harder words are worth more points."),
        HowStep(icon: "pencil.and.scribble", title: "Draw it",
                text: "Sketch with no letters or numbers. Hint letters appear as the timer runs down."),
        HowStep(icon: "bubble.left.fill", title: "Shout your guess",
                text: "Everyone else guesses out loud. When someone nails it, tap Guessed it and pick who got it."),
        HowStep(icon: "trophy.fill", title: "Score big",
                text: "Faster guesses earn more points and the drawer scores too. Most points after all rounds wins.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "How to Play", onBack: onBack)
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                Circle().fill(Palette.yellow)
                                Text("\(index + 1)")
                                    .font(.system(.headline, design: .rounded, weight: .black))
                                    .foregroundStyle(Palette.navy)
                            }
                            .frame(width: 36, height: 36)

                            VStack(alignment: .leading, spacing: 4) {
                                Label(step.title, systemImage: step.icon)
                                    .font(.system(.headline, design: .rounded, weight: .heavy))
                                    .foregroundStyle(Color.white)
                                Text(step.text)
                                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                                    .foregroundStyle(Color.white.opacity(0.75))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }

                    Toggle(isOn: $hapticsOn) {
                        Label("Haptic feedback", systemImage: "iphone.radiowaves.left.and.right")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                    .tint(Palette.teal)
                    .padding(14)
                    .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    ContentView()
}
