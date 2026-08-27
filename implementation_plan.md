# 📋 Floating Navbar & Scroll Footer Glitch Fix — Implementation Plan

**Feature:** Resolution of Fixed Footer Container Behind Floating `CelestialBottomNavbar`  
**Repository:** `The Remainder Portal` (`https://github.com/JAFAR564/remainder-portal`)  
**Status:** 🟢 Completed  
**Date:** August 27, 2026  

---

## 🔍 1. Problem Analysis & Root Cause

### The Glitch:
When scrolling up and down on screens (`Dashboard`, `Expeditions`, `Guilds`, `Settings`), the floating navigation pill remains fixed, but an opaque rectangular footer container appears behind and around the curved pill, abruptly truncating the scrolling content above it.

### Root Cause:
1. In Flutter, `Scaffold.extendBody` defaults to `false`. When `bottomNavigationBar` is provided, Flutter's `ScaffoldLayout` reserves a fixed, opaque rectangular strip across the full width and height of the bottom screen slot.
2. Because `CelestialBottomNavbar` is styled with rounded pill borders (`borderRadius: BorderRadius.circular(30)`) and margins (`margin: 16dp horizontal, 12dp bottom`), the rectangular bounding box behind the pill renders as a solid, detached footer background container.
3. The scrollable content stops at the top of this box instead of flowing continuously beneath the floating pill.

---

## 🛠️ 2. Step-by-Step Implementation Plan

### Step 1: Enable `extendBody: true` on `MainNavigationShell`
* **File:** `lib/presentation/screens/main_navigation_shell.dart`
* **Change:** Set `extendBody: true` on the root `Scaffold`. This allows the `IndexedStack` body to flow seamlessly to the bottom edge of the physical display underneath the floating navigation bar.

### Step 2: Ensure Outer Transparency in `CelestialBottomNavbar`
* **File:** `lib/presentation/widgets/celestial_bottom_navbar.dart`
* **Change:** Ensure the outer `SafeArea` and wrapper contain zero opaque background colors, allowing the underlying page content to be visible in the margins around the white pill.

### Step 3: Add Scroll Bottom Insets ($\approx 96\text{dp}$) Across All Root Screens
To ensure the bottom-most items can be scrolled completely clear of the floating bar, update the scroll padding across all screens:
1. `lib/presentation/screens/dashboard_screen.dart` $\rightarrow$ `padding: EdgeInsets.fromLTRB(20, 20, 20, 96)`
2. `lib/presentation/screens/expedition_screen.dart` $\rightarrow$ `padding: EdgeInsets.fromLTRB(16, 16, 16, 96)`
3. `lib/presentation/screens/guild_screen.dart` $\rightarrow$ `padding: EdgeInsets.fromLTRB(16, 16, 16, 96)`
4. `lib/presentation/screens/settings_screen.dart` $\rightarrow$ `padding: EdgeInsets.fromLTRB(16, 16, 16, 96)`

### Step 4: Adjust `TerminalScreen` Input Bar Alignment
* **File:** `lib/presentation/screens/terminal_screen.dart`
* **Change:** In `TerminalScreen`, ensure the bottom chat input bar sits properly above the floating navbar or includes bottom clearance so the input bar and keyboard interaction remain smooth and unobstructed.

---

## 🛡️ 3. Risk Identification & Mitigation Matrix

| Risk | Severity | Mitigation Strategy |
| :--- | :---: | :--- |
| **Bottom Content Obscured** | 🔴 High | Add explicit $96\text{dp}$ bottom scroll insets to all root screens so all cards/buttons can scroll fully above the pill. |
| **Chat Input Bar Overlap in Terminal** | 🟠 Medium | Add appropriate bottom insets / padding to the message input container in `TerminalScreen`. |
| **System Navigation Bar Clashes** | 🟡 Low | Preserve `SafeArea(bottom: true)` with transparent background inside `CelestialBottomNavbar`. |

---

## 📂 4. Files to Modify

1. `lib/presentation/screens/main_navigation_shell.dart`
2. `lib/presentation/widgets/celestial_bottom_navbar.dart`
3. `lib/presentation/screens/dashboard_screen.dart`
4. `lib/presentation/screens/expedition_screen.dart`
5. `lib/presentation/screens/guild_screen.dart`
6. `lib/presentation/screens/settings_screen.dart`
7. `lib/presentation/screens/terminal_screen.dart`
8. `ACTIVE_TASK.md`
