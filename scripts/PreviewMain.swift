import AgentBridge
import AppKit
import SwiftUI

/// Real SwiftUI/AppKit views with explicitly synthetic data. All writes use an
/// isolated support directory and preferences suite. No Spotify Apple Events,
/// GitHub requests, agent hooks, or production AppDelegate are started.
@main
struct BroschyPreviewMain {
    @MainActor static func main() {
        let application = NSApplication.shared
        application.setActivationPolicy(.accessory)
        Task { @MainActor in
            do {
                let arguments = CommandLine.arguments.dropFirst()
                let destination = arguments.first(where: { !$0.hasPrefix("--") }) ?? "build/previews"
                let previews = try PreviewSession(destination: destination)
                retainedSession = previews
                if arguments.contains("--show-only") { try await previews.prepareModels() }
                else { try await previews.captureAll() }
                if arguments.contains("--show") || arguments.contains("--show-only") {
                    previews.showInteractive(dark: !arguments.contains("--light"))
                } else {
                    previews.cleanUp()
                    application.terminate(nil)
                }
            } catch {
                fputs("Preview failed: \(error)\n", stderr)
                retainedSession?.cleanUp()
                exit(1)
            }
        }
        application.run()
    }

    @MainActor private static var retainedSession: PreviewSession?
}

@MainActor
private final class PreviewSession: NSObject, NSWindowDelegate {
    let destination: URL
    let scratch: URL
    let suiteName = "app.broschy.ui-preview." + UUID().uuidString
    let defaults: UserDefaults
    let store: FlowStore
    let state = PanelState()
    let spotify: SpotifyController
    let agents: AgentMonitor
    let preferences: PanelPreferences
    let builds: BuildWatchMonitor
    var window: NSWindow?
    let now = Date()
    var cleanedUp = false

    init(destination: String) throws {
        self.destination = URL(fileURLWithPath: destination, isDirectory: true)
        scratch = FileManager.default.temporaryDirectory.appendingPathComponent("broschy-preview-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: scratch, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: self.destination, withIntermediateDirectories: true)
        defaults = UserDefaults(suiteName: suiteName)!
        store = FlowStore(supportDirectory: scratch, startTicker: false)
        agents = AgentMonitor(rootDirectory: scratch.appendingPathComponent("agents"), startTicker: false)
        preferences = PanelPreferences(defaults: defaults)
        let track = SpotifySnapshot(id: "preview-track", title: "A little room to think", artist: "Broschy · Sample track",
            album: "Preview", artworkURL: nil, duration: 248, position: 92, isPlaying: true, volume: 65)
        spotify = SpotifyController(defaults: defaults, startTicker: false,
            perform: { _, _ in SpotifyOutcome(status: .connected, snapshot: track) })
        let fixtureDate = now
        builds = BuildWatchMonitor(defaults: defaults, startTicker: false, clock: { fixtureDate }, perform: { request, _ in
            let isSecond = request.target.repository == "scope"
            let run = BuildWatchRun(id: isSecond ? 2 : 1, name: "Build and test", headBranch: "main",
                headSHA: String(repeating: "a", count: 40),
                htmlURL: URL(string: "https://github.com/\(request.target.owner)/\(request.target.repository)/actions/runs/\(isSecond ? 2 : 1)")!,
                createdAt: fixtureDate.addingTimeInterval(-75), updatedAt: fixtureDate,
                status: isSecond ? .completed : .inProgress, conclusion: isSecond ? .success : nil, attempt: 1)
            return .success(.init(runs: [run], resolvedBranch: "main", scopeIdentity: "main"))
        })
        super.init()
        state.panelWidth = 480
        state.notchWidth = 200
        state.notchHeight = 38
        state.menuBarHeight = 38
        state.reduceMotion = true
        state.reduceTransparency = true
        state.shortcutAvailable = true
        state.expanded = true
        state.canvasExpanded = true
        state.pinned = true
        store.taskTitle = "Make room for your next idea."
        store.note = "After this session…\n\nRefine the first impression.\nKeep the useful things close.\nLeave a little space to think."
        let jobs = [
            FlowJob(id: UUID().uuidString, title: "Release build", status: .running,
                startedAt: now.addingTimeInterval(-84), finishedAt: nil, exitCode: nil, workingDirectory: "/Projects/Broschy"),
            FlowJob(id: UUID().uuidString, title: "Core checks", status: .succeeded,
                startedAt: now.addingTimeInterval(-180), finishedAt: now.addingTimeInterval(-158), exitCode: 0, workingDirectory: "/Projects/Broschy")
        ]
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        for job in jobs {
            try encoder.encode(job).write(to: scratch.appendingPathComponent("jobs/\(job.id).json"))
        }
        store.tick()
        agents.setPreviewSessions([
            AgentSession(provider: .claude, sessionID: "preview-claude", cwd: "/Projects/Broschy",
                status: .needsAttention, detail: "Waiting for permission", updatedAt: now,
                pendingRequestIDs: ["preview-request"], lastEvent: "PermissionRequest"),
            AgentSession(provider: .codex, sessionID: "preview-codex", cwd: "/Projects/portfolio",
                status: .working, detail: "Using a tool", updatedAt: now, lastEvent: "PreToolUse"),
            AgentSession(provider: .opencode, sessionID: "preview-opencode", cwd: "/Projects/scope",
                status: .ready, detail: "Ready to review", updatedAt: now, lastEvent: "session.idle")
        ])
        let iconURL = Bundle.main.resourceURL?.appendingPathComponent("AppIcon.png")
        if let icon = iconURL.flatMap({ NSImage(contentsOf: $0) }) ?? NSImage(contentsOfFile: "Resources/AppIcon.png") {
            icon.setName("AppIcon")
        }
    }

    func prepareModels() async throws {
        spotify.connect()
        _ = builds.add("dalkedev/Broschy")
        _ = builds.add("SculptTechProject/scope")
        for _ in 0..<200 {
            if spotify.status == .connected && !builds.isRefreshing { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        guard spotify.status == .connected, !builds.isRefreshing else {
            throw NSError(domain: "BroschyPreview", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fixture transport did not settle"])
        }
    }

    func captureAll() async throws {
        try await prepareModels()
        for dark in [false, true] {
            let suffix = dark ? "dark" : "light"
            for (name, tab, signalPage) in [("focus", 0, 0), ("agents", 4, 0), ("music", 3, 0),
                                          ("build-watch", 1, 0), ("commands", 1, 1), ("later", 2, 0)] {
                state.expanded = true
                state.canvasExpanded = true
                state.tab = tab
                state.signalPage = signalPage
                try await capture(root(dark: dark), size: CGSize(width: state.canvasWidth, height: state.canvasHeight),
                    name: "\(name)-\(suffix)", dark: dark)
            }
            store.start(minutes: 25)
            store.tick(now: Date().addingTimeInterval(7 * 60 + 18))
            state.tab = 0
            try await capture(root(dark: dark), size: CGSize(width: state.canvasWidth, height: state.canvasHeight),
                name: "focus-running-\(suffix)", dark: dark)
            state.expanded = false
            state.canvasExpanded = false
            for (name, content) in [("focus", CompactContent.focus), ("music", .music), ("agents", .agents), ("build-watch", .buildWatch)] {
                state.compactContent = content
                try await capture(root(dark: dark), size: CGSize(width: state.canvasWidth, height: state.canvasHeight),
                    name: "compact-\(name)-\(suffix)", dark: dark)
            }
            // The production fallback uses a 180-point center gap on displays
            // without a physical notch. Exercise its 24-point menu-bar band.
            state.notchWidth = 180
            state.notchHeight = 28
            state.menuBarHeight = 24
            for (name, content) in [("music", CompactContent.music), ("agents", .agents), ("build-watch", .buildWatch)] {
                state.compactContent = content
                try await capture(root(dark: dark), size: CGSize(width: state.canvasWidth, height: state.canvasHeight),
                    name: "compact-24pt-\(name)-\(suffix)", dark: dark)
            }
            state.notchWidth = 200
            state.notchHeight = 38
            state.menuBarHeight = 38
            store.resetTimer()
            let settings = PanelSettingsView(preferences: preferences)
                .background(Ink.surface)
                .environment(\.colorScheme, dark ? .dark : .light)
                .environment(\.flowReduceMotion, true)
                .environment(\.flowReduceTransparency, true)
            let settingsSize = NSHostingView(rootView: settings).fittingSize
            try await capture(settings, size: settingsSize, name: "settings-\(suffix)", dark: dark)
        }
        spotify.disconnect()
        agents.setPreviewSessions([])
        for id in builds.repositories.map(\.id) { builds.remove(id) }
        state.expanded = true
        state.canvasExpanded = true
        state.signalPage = 0
        for dark in [false, true] {
            for (name, tab) in [("music", 3), ("agents", 4), ("build-watch", 1)] {
                state.tab = tab
                try await capture(root(dark: dark), size: CGSize(width: state.canvasWidth, height: state.canvasHeight),
                    name: "\(name)-empty-\(dark ? "dark" : "light")", dark: dark)
            }
        }
        state.tab = 0
        let cover = ZStack(alignment: .topLeading) {
            Color(red: 0.956, green: 0.944, blue: 0.913)
            VStack(alignment: .leading, spacing: 18) {
                if let icon = NSImage(named: "AppIcon") {
                    Image(nsImage: icon).resizable().scaledToFit().frame(width: 76, height: 76)
                }
                Text("Broschy").font(.system(size: 43, weight: .bold)).tracking(-1.8)
                Text("A little more space to focus.")
                    .font(.system(size: 26, weight: .medium)).tracking(-0.5)
                    .fixedSize(horizontal: false, vertical: true)
                Rectangle().fill(Color(red: 1, green: 0.36, blue: 0.14)).frame(width: 42, height: 4)
                Text("Native macOS companion")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(Color(red: 0.12, green: 0.13, blue: 0.13))
            .frame(width: 235, alignment: .leading).offset(x: 34, y: 72)
            root(dark: true)
                .frame(width: state.canvasWidth, height: state.canvasHeight)
                .offset(x: 300, y: 34)
            Text("Preview with sample data")
                .font(.system(size: 10)).foregroundStyle(Color(red: 0.38, green: 0.38, blue: 0.36))
                .offset(x: 34, y: 477)
        }.frame(width: 800, height: 500)
        try await capture(cover, size: CGSize(width: 800, height: 500), name: "portfolio-cover", dark: true)
        print("Native previews saved to \(destination.path). All data is synthetic; integrations are mocked.")
    }

    func root(dark: Bool) -> some View {
        NotchRootView(store: store, state: state, spotify: spotify, agents: agents, preferences: preferences, builds: builds)
            .environment(\.colorScheme, dark ? .dark : .light)
    }

    func capture<Content: View>(_ content: Content, size: CGSize, name: String, dark: Bool) async throws {
        window?.orderOut(nil)
        let appearance = NSAppearance(named: dark ? .darkAqua : .aqua)!
        NSApp.appearance = appearance
        let host = NSHostingView(rootView: content)
        host.appearance = appearance
        host.frame = CGRect(origin: .zero, size: size)
        let nextWindow = NSPanel(contentRect: CGRect(origin: CGPoint(x: 120, y: 120), size: size),
            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        nextWindow.isReleasedWhenClosed = false
        nextWindow.isOpaque = false
        nextWindow.backgroundColor = .clear
        nextWindow.hasShadow = false
        nextWindow.appearance = appearance
        nextWindow.contentView = host
        nextWindow.orderFrontRegardless()
        window = nextWindow
        try await Task.sleep(for: .milliseconds(160))
        host.layoutSubtreeIfNeeded()
        host.displayIfNeeded()
        guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width * 2), pixelsHigh: Int(size.height * 2),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else {
            throw NSError(domain: "BroschyPreview", code: 2)
        }
        bitmap.size = size
        // cacheDisplay preserves native controls, unlike ImageRenderer. On some
        // macOS versions it loses the tint of a few SF symbols in Light captures.
        // Verify those live with --show-only --light; use Dark captures for
        // published imagery. This is an offscreen renderer limitation, not UI.
        appearance.performAsCurrentDrawingAppearance { host.cacheDisplay(in: host.bounds, to: bitmap) }
        guard let png = bitmap.representation(using: .png, properties: [:]) else { throw NSError(domain: "BroschyPreview", code: 3) }
        try png.write(to: destination.appendingPathComponent(name + ".png"))
        print("Captured \(name) (\(bitmap.pixelsWide) × \(bitmap.pixelsHigh))")
    }

    func showInteractive(dark: Bool) {
        NSApp.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
        // Match the shipping app's native responder-chain editing shortcuts.
        let mainMenu = NSMenu()
        let applicationItem = NSMenuItem()
        let applicationMenu = NSMenu(title: "Broschy Preview")
        applicationMenu.addItem(NSMenuItem(title: "Quit Broschy Preview", action: #selector(quitPreview), keyEquivalent: "q"))
        applicationMenu.items[0].target = self
        applicationItem.submenu = applicationMenu
        mainMenu.addItem(applicationItem)
        let editItem = NSMenuItem(title: "Edit", action: nil, keyEquivalent: "")
        let edit = NSMenu(title: "Edit")
        for (title, action, key) in [("Undo", "undo:", "z"), ("Cut", "cut:", "x"), ("Copy", "copy:", "c"), ("Paste", "paste:", "v"), ("Select All", "selectAll:", "a")] {
            edit.addItem(NSMenuItem(title: title, action: Selector(action), keyEquivalent: key))
        }
        editItem.submenu = edit
        mainMenu.addItem(editItem)
        NSApp.mainMenu = mainMenu
        state.expanded = true
        state.canvasExpanded = true
        state.tab = 0
        state.close = { [weak self] in self?.cleanUp(); NSApp.terminate(nil) }
        window?.orderOut(nil)
        let size = CGSize(width: state.canvasWidth, height: state.canvasHeight)
        let preview = NSWindow(contentRect: CGRect(origin: .zero, size: size),
            styleMask: [.titled, .closable], backing: .buffered, defer: false)
        preview.title = "Broschy Preview — isolated sample data"
        preview.isReleasedWhenClosed = false
        preview.appearance = NSApp.appearance
        preview.contentView = NSHostingView(rootView: root(dark: dark))
        preview.delegate = self
        preview.center()
        preview.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        window = preview
    }

    @objc func quitPreview() {
        cleanUp()
        NSApp.terminate(nil)
    }

    func windowWillClose(_ notification: Notification) {
        cleanUp()
        NSApp.terminate(nil)
    }

    func cleanUp() {
        guard !cleanedUp else { return }
        cleanedUp = true
        store.saveNow()
        defaults.removePersistentDomain(forName: suiteName)
        try? FileManager.default.removeItem(at: scratch)
    }
}
