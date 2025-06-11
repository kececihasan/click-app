# Fix Xcode Folder Reference Issue

## Problem
You renamed your folder from "TapCounter" to "MathRush" but Xcode still shows the old folder name.

## ✅ Alternative Xcode Methods (When Right-Click Rename Isn't Available)

### Method 1: Select and Press Enter
1. **Open Xcode** and your project
2. In the **Project Navigator** (left sidebar), **single-click** to select the folder that shows "TapCounter"
3. **Press Enter** key (this should make the name editable)
4. **Type "MathRush"** and press Enter again
5. **Clean and rebuild** your project (⌘+Shift+K, then ⌘+B)

### Method 2: File Inspector Method
1. **Select the folder** in Project Navigator
2. **Open File Inspector** (right sidebar, or View → Navigators → Show File Inspector)
3. Look for **"Name"** field in the inspector
4. **Change the name** from "TapCounter" to "MathRush"
5. **Clean and rebuild** your project

### Method 3: Project Settings
1. **Click on your project name** at the very top of Project Navigator
2. In the main editor, look at **"Project Document"** section
3. Find any references to "TapCounter" and change to "MathRush"

### Method 4: Remove and Re-add Folder
1. **Right-click** the "TapCounter" folder → **"Remove References Only"** (NOT delete!)
2. **Right-click** in Project Navigator → **"Add Files to [ProjectName]"**
3. **Navigate to and select** your "MathRush" folder
4. **Click "Add"**

## 🔧 Manual Fix (Most Reliable)

### Close Xcode and Edit Project File Directly:
1. **Completely close Xcode**
2. **Right-click** on `TapCounter.xcodeproj` → **"Show Package Contents"**
3. **Open** `project.pbxproj` in any text editor (TextEdit, VS Code, etc.)
4. **Find and replace ALL instances** of:
   ```
   Find: TapCounter
   Replace: MathRush
   ```
   **BUT ONLY for these specific types:**
   - `path = TapCounter;` → `path = MathRush;`
   - `"TapCounter/Preview Content"` → `"MathRush/Preview Content"`
   - Any folder group names that say `/* TapCounter */`

5. **Save** the file
6. **Reopen Xcode**

## 🔍 What This Fixes

- **Folder References**: Updates internal Xcode references to point to correct folder
- **Build Paths**: Fixes preview content and asset paths
- **Project Structure**: Ensures Xcode Navigator shows correct folder name

## ⚠️ Important Notes

- **Always close Xcode** before editing .pbxproj files manually
- **Make a backup** of your project before making changes
- **Clean build folder** after changes (⌘+Shift+K)
- If you have team members, they'll need to **pull the updated project file**

## 🚨 What NOT to Change
When editing manually, **DON'T change**:
- Product names like `TapCounter.app`
- Bundle identifiers
- Target names (unless you want to rename the whole project)

## ✅ Verification

After fixing:
1. **Project Navigator** should show "MathRush" folder
2. **Build should succeed** without path errors
3. **Preview** should work correctly
4. **No red/missing file** references in Xcode

---

*This issue occurs because Xcode stores internal folder references that don't automatically update when you rename folders outside of Xcode.* 