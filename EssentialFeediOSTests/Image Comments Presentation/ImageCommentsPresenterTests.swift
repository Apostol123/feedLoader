//
//  ImageCommentsPresenterTests.swift
//  EssentialFeediOSTests
//
//  Created by Alex.personal on 9/1/24.
//

import XCTest
import FeedLoader

final class ImageCommentsPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    func test_map_createsViewModels() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        let comments = [
            ImageComments(id: UUID(), message: "a message", createdAt: now.adding(minutes: -5, calendar: calendar), username: "a username"),
            ImageComments(id: UUID(), message: "another message", createdAt: now.adding(days: -1, calendar: calendar), username: "another username")
        ]
        
        let viewModel = ImageCommentsPresenter.map(
            comments,
            currentDate: now,
            calendar: calendar,
            locale: locale)
        
        XCTAssertEqual(viewModel.comments, [
            ImageCommentViewModel(
                message: "a message",
                date: "5 minutes ago",
                username: "a username"
            ),
            ImageCommentViewModel(
                message: "another message",
                date: "1 day ago",
                username: "another username"
            )
        ])
    }
    
    //MARK: - Helpers
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table \(table)", file: file, line: line)
        }
        
        return value
    }
    

}

public extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
    
    func adding(minutes: Int, calendar: Calendar = .current) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: self)!
    }
    
     func adding(days: Int, calendar: Calendar = .current) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}
