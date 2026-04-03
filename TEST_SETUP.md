# Test Setup Guide

## Quick Fix for Test Errors

The test files were created in the wrong location. Follow these steps to set up testing correctly:

### Step 1: Clean Up Incorrectly Placed Files

Delete these files from your project root:
- `CodeEditorTestsCodeDocumentTests.swift`
- `CodeEditorTestsFindReplaceTests.swift`
- `CodeEditorUITestsCodeEditorUITests.swift`

### Step 2: Add Test Targets in Xcode

1. **Add Unit Testing Bundle:**
   - File → New → Target
   - Select "Unit Testing Bundle"
   - Name: `CodeEditorTests`
   - Click Finish

2. **Add UI Testing Bundle:**
   - File → New → Target
   - Select "UI Testing Bundle"
   - Name: `CodeEditorUITests`
   - Click Finish

### Step 3: Add Test Files to Correct Targets

#### For Unit Tests:

1. Right-click `CodeEditorTests` folder in Project Navigator
2. New File → Swift File
3. Name: `CodeDocumentTests.swift`
4. **IMPORTANT:** Check "CodeEditorTests" target ONLY
5. Copy content from `/repo/Tests/CodeDocumentTests.swift`
6. Repeat for `FindReplaceTests.swift`

#### For UI Tests:

1. Right-click `CodeEditorUITests` folder
2. New File → Swift File
3. Name: `CodeEditorUITests.swift`
4. **IMPORTANT:** Check "CodeEditorUITests" target ONLY
5. Copy content from the UI tests file

### Step 4: Configure Test Targets

1. **Select CodeEditorTests target**
2. Build Phases → Target Dependencies
3. Add "CodeEditor" (your main app target)

4. **Select CodeEditorUITests target**
5. Build Phases → Target Dependencies
6. Add "CodeEditor"

### Step 5: Enable @testable Import

For both test targets:
1. Select target
2. Build Settings
3. Search for "Enable Testability"
4. Set to "Yes" for Debug configuration

### Step 6: Run Tests

```bash
# In Xcode:
⌘U to run all tests

# Or:
Product → Test
```

---

## Alternative: Simple XCTest Setup

If the above seems complex, here's the minimal approach:

### Option A: Use Existing Test Targets

If you already have test targets:

1. Open Project Navigator
2. Find existing `CodeEditorTests` group/folder
3. Right-click → New File
4. Choose Swift File
5. Name it `CodeDocumentTests.swift`
6. Make sure ONLY test target is checked
7. Paste code from `/repo/Tests/CodeDocumentTests.swift`

### Option B: Create Single Test File

Just create one test file to start:

1. Find `CodeEditorTests` folder
2. Delete the default test file (if exists)
3. Create new Swift file
4. Use this minimal test:

```swift
import XCTest
@testable import CodeEditor

final class BasicTests: XCTestCase {
    func testLanguageDetection() {
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.swift"), .swift)
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.py"), .python)
    }
    
    func testFindReplace() {
        let content = "Hello World"
        let result = content.replacingOccurrences(of: "World", with: "Swift")
        XCTAssertEqual(result, "Hello Swift")
    }
}
```

---

## Troubleshooting

### Error: "No such module 'Testing'"
- **Solution:** Use XCTest files from `/repo/Tests/` folder instead
- Swift Testing requires Xcode 16+ / Swift 6+
- XCTest works on all versions

### Error: "Unable to find module dependency: 'XCTest'"
- **Solution:** File is not in a test target
- Add file to test target via Target Membership inspector

### Error: "@testable import CodeEditor failed"
- **Solution:** Enable testability
- Build Settings → Enable Testability → Yes

### Tests don't appear in Test Navigator
- **Solution:** Rebuild project (⌘B)
- Clean build folder (⌘⇧K)

---

## File Locations

The corrected XCTest files are in `/repo/Tests/`:
- `CodeDocumentTests.swift` - XCTest version
- `FindReplaceTests.swift` - XCTest version

The UI test file is in your project root as created.

---

## Quick Start (Absolute Minimum)

If you just want to verify testing works:

1. In Xcode, create ONE test file in CodeEditorTests
2. Copy this code:

```swift
import XCTest
@testable import CodeEditor

final class QuickTest: XCTestCase {
    func testExample() {
        XCTAssertTrue(true)
    }
}
```

3. Press ⌘U
4. If you see green checkmark ✓, testing works!
5. Then add the full test files

---

## Need Help?

If you're still stuck:

1. Show me a screenshot of your Project Navigator
2. Show me the error messages
3. Tell me what Xcode version you're using

I can provide more specific guidance!
