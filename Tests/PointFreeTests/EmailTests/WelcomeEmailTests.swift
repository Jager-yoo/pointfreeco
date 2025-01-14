import Dependencies
import Either
import Html
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import GitHub
@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

@MainActor
final class WelcomeEmailIntegrationTests: LiveDatabaseTestCase {
  @Dependency(\.database) var database

  func testIncrementEpisodeCredits() async throws {
    var users: [User] = []
    for id in [1, 2, 3] {
      var env = GitHubUserEnvelope.mock
      env.gitHubUser.id = .init(rawValue: id)
      try await users.append(
        self.database.registerUser(
          withGitHubEnvelope: env, email: .init(rawValue: "\(id)@pointfree.co"), now: { .mock }
        )
      )
    }

    _ = try await self.database.incrementEpisodeCredits(users.map(\.id))

    var updatedUsers: [User] = []
    for user in users {
      try await updatedUsers.append(self.database.fetchUserById(user.id))
    }

    zip(users, updatedUsers).forEach {
      XCTAssertEqual($0.episodeCreditCount + 1, $1.episodeCreditCount)
    }
  }
}

@MainActor
final class WelcomeEmailTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording=true
  }

  func testWelcomeEmail1() async throws {
    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let emailNodes = welcomeEmailView("", welcomeEmail1Content)(.newUser)

        await assertSnapshot(matching: emailNodes, as: .html)

        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        await assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }

  func testWelcomeEmail2() async throws {
    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let emailNodes = welcomeEmailView("", welcomeEmail2Content)(.newUser)

        await assertSnapshot(matching: emailNodes, as: .html)

        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        await assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }

  func testWelcomeEmail3() async throws {
    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let emailNodes = welcomeEmailView("", welcomeEmail3Content)(.newUser)

        await assertSnapshot(matching: emailNodes, as: .html)

        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        await assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }

  func testEpisodeEmails() async throws {
    _ = try await sendWelcomeEmails().performAsync()
  }
}
