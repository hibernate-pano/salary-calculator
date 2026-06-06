//
//  salary_calculatorUITests.swift
//  salary-calculatorUITests
//

import XCTest

final class salary_calculatorUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// 走完引导页 → 进入主界面 → 截图，验证实时工资界面正常渲染。
    @MainActor
    func testOnboardingToEarnings() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-resetOnboarding"]
        app.launch()

        // 走完引导页（最多 5 次点击「下一步」/「开始使用」）
        for _ in 0..<5 {
            let next = app.buttons["下一步"]
            let start = app.buttons["开始使用"]
            if start.exists && start.isHittable {
                start.tap()
                break
            } else if next.exists && next.isHittable {
                next.tap()
            } else {
                break
            }
        }

        // 进入主界面后应能看到「今日收入」标题
        let todayLabel = app.staticTexts["今日收入"]
        XCTAssertTrue(todayLabel.waitForExistence(timeout: 5), "主界面应显示今日收入")

        // 截两张图（间隔便于人工核对数字是否变化）
        attachScreenshot(app, name: "earnings-1")
        Thread.sleep(forTimeInterval: 2.5)
        attachScreenshot(app, name: "earnings-2")
    }

    private func attachScreenshot(_ app: XCUIApplication, name: String) {
        let shot = app.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
