//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Alex.personal on 9/1/24.
//

import XCTest
import FeedLoader

final class ImageCommentsLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let presentationBundle = Bundle(for: ImageCommentsPresenter.self)
        assertLocalizaedKeyAndValuesExist(in: presentationBundle, table)
    }
    
}
