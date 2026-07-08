# macOS Gatekeeper: Opening the Langflow Installer

When you double-click `Install Langflow.command` on macOS, you may see:

> **"Langflow Installer" cannot be opened because the developer cannot be verified.**

This is Gatekeeper protecting you from unsigned software. The installer is a plain-text shell script (not malware), but it isn't signed with an Apple Developer ID, so macOS blocks it by default.

## One-time fix via System Settings

1. **Try double-clicking the file first.** The dialog will appear.

2. Click **Done** or **Cancel** to dismiss it.

3. Open **System Settings** (or System Preferences on older macOS).

4. Go to **Privacy & Security**.

   - macOS 13+ (Ventura / Sonoma / Sequoia): It is in the sidebar.
   - macOS 12 (Monterey) and earlier: It is a pane near the top.

5. Scroll down to the **Security** section.

6. Look for a message like:

   > **"Install Langflow.command" was blocked from use.**

7. Click **Open Anyway** next to that message.

8. Authenticate with your **password** or **Touch ID** when prompted.

9. A final dialog will appear asking you to confirm. Click **Open**.

10. The Terminal will open and the installer menu will appear.

This is a **one-time step per file**. Once you have allowed `Install Langflow.command`, future double-clicks will work without prompting. The same process applies to any other `.command` files extracted from the zip (such as the launcher and stop scripts).

## Why this happens

- The `.command` file was downloaded from the internet, so macOS attaches a **quarantine attribute** to it.
- Gatekeeper checks the quarantine and looks for a valid code signature.
- Since the file is not signed, Gatekeeper blocks it by default.

This is standard macOS behavior for any unsigned downloaded executable — the same thing happens with many open-source tools, Homebrew formulas, and command-line utilities.

## Alternative: remove the quarantine attribute

If you prefer working in Terminal, you can bypass Gatekeeper manually:

```bash
# Navigate to the extracted folder
cd /path/to/extracted/folder

# Remove the quarantine attribute from all .command files
xattr -d com.apple.quarantine Install\ Langflow.command
xattr -d com.apple.quarantine Stop\ Langflow.command

# Now double-clicking will work without Gatekeeper
```

This removes the "downloaded from the internet" flag. The files will run without any prompt from that point on.
