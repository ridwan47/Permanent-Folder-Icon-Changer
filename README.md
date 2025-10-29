# Permanent-Folder-Icon-Changer
Permanent Folder Icon Changer lets you easily set and keep custom icons for any folder. It copies the chosen icon into the folder, applies it permanently, and logs every action. Supports drag &amp; drop, multi-folder scanning, and right-click menu integration for quick access. Reliable, simple, and permanent.



Here’s a **ready-to-use README / Description** for your `.exe` version of the batch file. It’s written in a professional and informative tone but still approachable — suitable for inclusion on GitHub, a release page, or a “ReadMe.txt” next to the executable.

---

# 🗂️ Permanent Folder Icon Changer

**by ridwan47 (Modified Edition — Always Copies Icons)**

## 📘 Overview

**Permanent Folder Icon Changer** is a powerful, menu-driven Windows utility that allows you to **change and permanently set custom icons for any folder** on your system.
It automatically handles `desktop.ini` creation, hidden attributes, and instant Explorer refresh — all while ensuring your selected icon file is safely **copied into the folder** (so your custom icon never breaks, even if the source file is moved or deleted).

This tool is a compiled `.exe` version of a batch-based system utility for convenience and reliability.

---

## ✨ Key Features

✅ **Permanent Icons:**
Copies the chosen `.ico` or `.exe` icon file directly into the target folder before applying it — ensuring your icons never reset or disappear.

✅ **Multiple Operation Modes:**

* **Browse Mode:** Choose any folder via a GUI picker.
* **Subfolder Scan Mode:** Automatically process all subfolders in a directory.
* **Manual / Drag & Drop Mode:** Paste or drag a folder directly onto the `.exe`.

✅ **Smart Detection:**
Finds `.ico` and `.exe` files within the folder and filters out irrelevant files automatically.

✅ **Automatic Debug Log:**
Every session generates a detailed log at:

```
%TEMP%\_folder_icon_debug.log
```

You can check it for troubleshooting or script behavior inspection.

✅ **Context Menu Integration (Optional):**
Install a **“Change Folder Icon”** entry in the **right-click context menu** for quick access.

* Works for both folder background and direct folder right-clicks.
* Uses a permanently stored icon in `C:\Windows\System32` for persistence.
* Requires **Administrator privileges** to install or uninstall.

✅ **Robust Design:**

* Handles spaces, special characters, and Unicode in paths.
* Auto-fallback if `FolderIconUpdater.exe` is missing or fails.
* Clean user prompts and progress feedback.

---

## ⚙️ How to Use

### 🔹 Normal Usage

1. **Double-click** the `.exe` file to open the main menu.
2. Choose one of the operation modes:

   * `1` → Browse for a single folder (GUI)
   * `2` → Process all subfolders in the current directory
   * `3` → Paste or drag a folder path manually
3. Follow on-screen instructions to pick or assign an icon.
4. The tool will automatically copy and apply the icon permanently.

### 🔹 Quick Use via Drag & Drop

Simply **drag a folder** and **drop it onto the `.exe` file** — it will start instantly for that folder.

### 🔹 Right-Click Context Menu (Optional)

To add “Change Folder Icon” to your folder right-click menu:

* Run the `.exe` as **Administrator**
* From the main menu, press `I` to **install** context menu support.

To remove it later:

* Run again as **Administrator**
* Press `U` to **uninstall** the context menu.

---

## 🧩 Requirements

* Windows 7, 8, 10, or 11
* `FolderIconUpdater.exe` (included or downloadable)
* Administrator privileges (for context menu setup)
* PowerShell (for folder and file browsing GUI)

---

## 📦 Included Files

| File                                | Description                                     |
| ----------------------------------- | ----------------------------------------------- |
| `Permanent Folder Icon Changer.exe` | Main program (compiled from batch)              |
| `resources\FolderIconUpdater.exe`   | Required component for setting icons            |
| `icon.ico`                          | Optional icon used for context menu integration |

---

## 🛠️ Troubleshooting

* **FolderIconUpdater.exe not found:**
  Edit the script’s internal configuration or ensure it exists under `resources\` folder.

* **Context menu doesn’t appear:**
  Make sure you ran the `.exe` as **Administrator** when installing it.

* **Icons not showing up immediately:**
  Press `F5` or reopen the folder to refresh Explorer’s view.

* **Debugging:**
  Open `%TEMP%\_folder_icon_debug.log` to see every logged action.

---

## 🧾 License & Credits

Developed and maintained by **ridwan47**
Modified version includes permanent icon copying logic and enhanced debug system.
Based on components from [Folder Icon Updater](https://github.com/ramdany7/Folder-Icon-Updater).

---

## 💡 Tip

Keep this tool somewhere permanent (like `C:\Tools\FolderIconChanger\`) so context menu paths remain valid.

---

Would you like me to make a **compact “ReadMe.txt” version** (same content but formatted for Notepad width — ~80 characters wide)? It would look clean and ready to include beside your `.exe`.
