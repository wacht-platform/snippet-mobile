import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    self.minSize = NSSize(width: 480, height: 520)
    self.title = "snippet"

    // Bring our own title bar: hide the native one and let Flutter draw the top
    // toolbar full-bleed under the (kept) traffic-light controls. Dragging any
    // empty background area moves the window — no extra plugin needed.
    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden
    self.styleMask.insert(.fullSizeContentView)
    self.isMovableByWindowBackground = true

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    // Open filling the screen's visible area (below the menu bar). Done AFTER
    // super so the storyboard's default frame doesn't override it.
    if let screen = self.screen ?? NSScreen.main {
      self.setFrame(screen.visibleFrame, display: true)
    }
  }
}
