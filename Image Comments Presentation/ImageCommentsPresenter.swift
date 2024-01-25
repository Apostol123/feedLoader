//
//  ImageCommentsPresenter.swift
//  EssentialFeediOSTests
//
//  Created by Alex.personal on 9/1/24.
//

import Foundation

public struct ImageCommentsViewModel: Equatable {
    public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Equatable, Hashable {
    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }
    
    public let message: String
    public let date: String
    public let username: String
}

public final class ImageCommentsPresenter {
    public static var title: String {
        return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle:  Bundle(for: ImageCommentsPresenter.self),
                          comment: "Title for the image comments view")
    }
    
    public static func map(
        _ comments: [ImageComments],
        currentDate: Date = Date(),
        calendar: Calendar = .current,
        locale: Locale = .current
    ) -> ImageCommentsViewModel {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.calendar = calendar
        
        
        return ImageCommentsViewModel(comments: comments.map({ comment in
            ImageCommentViewModel(
                message: comment.message,
                date: formatter.localizedString(for: comment.createdAt, relativeTo: currentDate),
                username: comment.username)
        }))
    }
}
