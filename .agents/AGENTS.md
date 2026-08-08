# Mac App Store Compliance (Standalone App)

When writing, reviewing, or modifying code for this project, always ensure that the implementation complies with Apple's Mac App Store guidelines. 

Specifically, the application must be completely self-contained (standalone):
- Do NOT introduce dependencies on external command-line tools, local binaries, or shell scripts to perform core logic. All functionalities should be implemented natively in Swift or properly bundled and sandboxed.
- Ensure the app respects the App Sandbox constraints (e.g., no arbitrary file system access without explicit user permission, no root privileges).
- Avoid any practices, dependencies, or architectures that would prevent the application from passing the Apple App Store review process.
