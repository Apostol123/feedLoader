//
//  ImageCommentsPresenter.swift
//  EssentialFeediOSTests
//
//  Created by Alex.personal on 9/1/24.
//

import Foundation

public final class ImageCommentsPresenter {
    public static var title: String {
        return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle:  Bundle(for: ImageCommentsPresenter.self),
                          comment: "Title for the image comments view")
    }
}
