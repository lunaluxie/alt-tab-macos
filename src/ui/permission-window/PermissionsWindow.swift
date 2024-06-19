import Cocoa

class PermissionsWindow: NSWindow, NSWindowDelegate {
    var accessibilityView: PermissionView!

    convenience init() {
        self.init(contentRect: .zero, styleMask: [.titled, .miniaturizable, .closable], backing: .buffered, defer: false)
        delegate = self
        setupWindow()
        setupView()
    }

    func show() {
        accessibilityView.updatePermissionStatus(SystemPermissions.accessibilityIsGranted())
        center()
        App.shared.activate(ignoringOtherApps: true)
        makeKeyAndOrderFront(nil)
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if !SystemPermissions.accessibilityIsGranted() {
            debugPrint("Before using this app, you need to give permission in System Preferences > Security & Privacy > Privacy > Accessibility.",
                "Please authorize and re-launch.",
                "See https://help.rescuetime.com/article/59-how-do-i-enable-accessibility-permissions-on-mac-osx",
                separator: "\n")
            App.shared.terminate(self)
        }
        return true
    }

    private func setupWindow() {
        title = NSLocalizedString("AltTab needs some permissions", comment: "")
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        styleMask.insert([.miniaturizable, .closable])
    }

    private func setupView() {
        let appIcon = NSImageView(image: NSImage.initResizedCopy("app", 80, 80))
        appIcon.imageScaling = .scaleNone
        let appText = TitleLabel(NSLocalizedString("AltTab needs some permissions", comment: ""))
        appText.preferredMaxLayoutWidth = 380
        appText.font = .systemFont(ofSize: 25, weight: .regular)
        let header = NSStackView(views: [appIcon, appText])
        header.spacing = GridView.interPadding
        accessibilityView = PermissionView(
            "accessibility",
            NSLocalizedString("Accessibility", comment: ""),
            NSLocalizedString("This permission is needed to focus windows after you release the shortcut", comment: ""),
            NSLocalizedString("Open Accessibility Preferences…", comment: ""),
            "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility",
            SystemPermissions.accessibilityIsGranted
        )
        var rows = [
            [header],
            [accessibilityView],
        ]
        let view = GridView(rows as! [[NSView]])
        view.fit()

        setContentSize(view.fittingSize)
        contentView = view
    }
}
