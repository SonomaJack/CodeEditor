//
//  CodeEditorUITests.swift
//  CodeEditorUITests
//
//  Created by J Bretcher on 4/3/26.
//

import XCTest

final class CodeEditorUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - File Operations Tests
    
    func testCreateNewFile() throws {
        // Click the + button or use menu
        let createButton = app.buttons["plus"]
        if createButton.exists {
            createButton.tap()
        } else {
            // Use keyboard shortcut
            app.typeKey("n", modifierFlags: .command)
        }
        
        // Verify new file sheet appears
        XCTAssertTrue(app.staticTexts["Create New File"].waitForExistence(timeout: 2))
        
        // Enter filename
        let filenameField = app.textFields.firstMatch
        filenameField.tap()
        filenameField.typeText("TestFile.swift")
        
        // Click create
        app.buttons["Create"].tap()
        
        // Verify file appears in sidebar
        XCTAssertTrue(app.staticTexts["TestFile.swift"].waitForExistence(timeout: 2))
    }
    
    func testOpenFindPanel() throws {
        // Use keyboard shortcut to open find
        app.typeKey("f", modifierFlags: .command)
        
        // Verify find panel appears
        XCTAssertTrue(app.searchFields.firstMatch.waitForExistence(timeout: 2))
        
        // Verify cursor is in search field (focused)
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.hasFocus)
    }
    
    func testOpenReplacePanel() throws {
        // Use keyboard shortcut to open replace
        app.typeKey("h", modifierFlags: [.command, .option])
        
        // Verify replace panel appears
        XCTAssertTrue(app.staticTexts["Replace"].waitForExistence(timeout: 2))
        
        // Verify both find and replace fields exist
        let textFields = app.textFields
        XCTAssertTrue(textFields.count >= 2)
    }
    
    func testOpenSettings() throws {
        // Use keyboard shortcut
        app.typeKey(",", modifierFlags: .command)
        
        // Verify settings window appears
        XCTAssertTrue(app.staticTexts["General"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Premium"].exists)
        XCTAssertTrue(app.staticTexts["About"].exists)
    }
    
    // MARK: - Settings Tests
    
    func testNavigateSettings() throws {
        // Open settings
        app.typeKey(",", modifierFlags: .command)
        
        // Click Premium tab
        app.buttons["Premium"].tap()
        XCTAssertTrue(app.staticTexts["Premium Features"].waitForExistence(timeout: 1))
        
        // Click About tab
        app.buttons["About"].tap()
        XCTAssertTrue(app.staticTexts["Code Editor"].waitForExistence(timeout: 1))
        
        // Click General tab
        app.buttons["General"].tap()
        XCTAssertTrue(app.staticTexts["General"].waitForExistence(timeout: 1))
    }
    
    func testFontSizeSlider() throws {
        // Open settings
        app.typeKey(",", modifierFlags: .command)
        
        // Find font size slider
        let slider = app.sliders.firstMatch
        XCTAssertTrue(slider.exists)
        
        // Adjust slider
        slider.adjust(toNormalizedSliderPosition: 0.5)
        
        // Verify font size label updates
        // (Check for "13 pt" or similar text)
    }
    
    func testToggleStatusBar() throws {
        // Open settings
        app.typeKey(",", modifierFlags: .command)
        
        // Find status bar toggle
        let toggle = app.checkBoxes["Show status bar"]
        if toggle.exists {
            let initialState = toggle.value as? Int
            toggle.tap()
            
            // Verify state changed
            let newState = toggle.value as? Int
            XCTAssertNotEqual(initialState, newState)
        }
    }
    
    // MARK: - Feedback Tests
    
    func testOpenFeedbackForm() throws {
        // Open settings
        app.typeKey(",", modifierFlags: .command)
        
        // Go to About tab
        app.buttons["About"].tap()
        
        // Click Send Feedback button
        let feedbackButton = app.buttons["Send Feedback"]
        if feedbackButton.waitForExistence(timeout: 2) {
            feedbackButton.tap()
            
            // Verify feedback form appears
            XCTAssertTrue(app.staticTexts["Send Feedback"].waitForExistence(timeout: 2))
        }
    }
    
    func testFeedbackFormFields() throws {
        // Open settings and navigate to feedback
        app.typeKey(",", modifierFlags: .command)
        app.buttons["About"].tap()
        app.buttons["Send Feedback"].tap()
        
        // Wait for form
        XCTAssertTrue(app.staticTexts["Send Feedback"].waitForExistence(timeout: 2))
        
        // Check feedback type picker exists
        let picker = app.popUpButtons.firstMatch
        XCTAssertTrue(picker.exists)
        
        // Check email field exists
        let emailField = app.textFields["email@example.com"]
        XCTAssertTrue(emailField.exists || app.textFields.count > 0)
        
        // Check feedback text area exists
        let textEditor = app.textViews.firstMatch
        XCTAssertTrue(textEditor.exists)
    }
    
    // MARK: - Find and Replace Tests
    
    func testFindText() throws {
        // Create a new file first (or open existing)
        app.typeKey("n", modifierFlags: .command)
        
        // Type some content (if editor is visible)
        // Note: May need to interact with text editor element
        
        // Open find
        app.typeKey("f", modifierFlags: .command)
        
        // Type search text
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("test")
        
        // Click Find All or press Enter
        let findButton = app.buttons["All"]
        if findButton.exists {
            findButton.tap()
        }
    }
    
    func testReplaceText() throws {
        // Open replace panel
        app.typeKey("h", modifierFlags: [.command, .option])
        
        // Type in search field
        let textFields = app.textFields
        if textFields.count >= 1 {
            textFields.element(boundBy: 0).tap()
            textFields.element(boundBy: 0).typeText("old")
        }
        
        // Type in replace field
        if textFields.count >= 2 {
            textFields.element(boundBy: 1).tap()
            textFields.element(boundBy: 1).typeText("new")
        }
        
        // Click Replace All button
        let replaceAllButton = app.buttons["Replace All"]
        if replaceAllButton.exists {
            replaceAllButton.tap()
        }
    }
    
    // MARK: - Keyboard Shortcuts Tests
    
    func testKeyboardShortcuts() throws {
        // Test various shortcuts
        
        // New File (⌘N)
        app.typeKey("n", modifierFlags: .command)
        sleep(1)
        
        // Close any dialogs
        let cancelButton = app.buttons["Cancel"]
        if cancelButton.exists {
            cancelButton.tap()
        }
        
        // Open (⌘O)
        app.typeKey("o", modifierFlags: .command)
        sleep(1)
        
        // Cancel open dialog
        if cancelButton.exists {
            cancelButton.tap()
        }
        
        // Find (⌘F)
        app.typeKey("f", modifierFlags: .command)
        XCTAssertTrue(app.searchFields.firstMatch.waitForExistence(timeout: 2))
    }
    
    // MARK: - Drag and Drop Tests
    
    func testDragAndDropVisualFeedback() throws {
        // This test would require actual file dragging
        // which is complex in UI tests
        // Manual testing recommended for drag and drop
    }
    
    // MARK: - Performance Tests
    
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }
    
    func testOpenFilePerformance() throws {
        measure {
            app.typeKey("o", modifierFlags: .command)
            
            // Cancel dialog
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.waitForExistence(timeout: 2) {
                cancelButton.tap()
            }
        }
    }
    
    // MARK: - Menu Tests
    
    func testMenuBarExists() throws {
        let menuBar = app.menuBars
        XCTAssertTrue(menuBar.menuItems.count > 0)
    }
    
    func testHelpMenu() throws {
        // Access Help menu
        let menuBar = app.menuBars
        let helpMenu = menuBar.menuBarItems["Help"]
        
        if helpMenu.exists {
            helpMenu.click()
            
            // Verify Help items exist
            XCTAssertTrue(app.menuItems["Code Editor Help"].exists ||
                         app.menuItems["Send Feedback..."].exists)
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyState() throws {
        // Launch app
        // Verify welcome screen appears when no files open
        let welcomeText = app.staticTexts["Code Editor"]
        XCTAssertTrue(welcomeText.exists || app.staticTexts["Create or open a file to start editing"].exists)
    }
    
    func testMultipleWindows() throws {
        // Open multiple windows
        app.typeKey("n", modifierFlags: .command)
        
        // Verify window count (if accessible)
        // This is platform-specific and may need adjustment
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    var hasFocus: Bool {
        return (self.value(forKey: "hasKeyboardFocus") as? Bool) ?? false
    }
}
