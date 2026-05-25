import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    
    let phoneWidth: CGFloat = 390
    let phoneHeight: CGFloat = 844
    let screenFrame = NSScreen.main?.frame ?? NSRect.zero
    let originX = (screenFrame.width - phoneWidth) / 2
    let originY = (screenFrame.height - phoneHeight) / 2
    let windowFrame = NSRect(x: originX, y: originY, width: phoneWidth, height: phoneHeight)
    self.setFrame(windowFrame, display: true)
    self.setContentSize(NSSize(width: phoneWidth, height: phoneHeight))

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
