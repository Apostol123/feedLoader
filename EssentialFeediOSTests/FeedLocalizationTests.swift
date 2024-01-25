//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Alex.personal on 11/10/23.
//

import XCTest
import FeedLoader
@testable import EssentialFeediOS

final class FeedLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let presentationBundle = Bundle(for: FeedPresenter.self)
        assertLocalizaedKeyAndValuesExist(in: presentationBundle, table)
    }

}
