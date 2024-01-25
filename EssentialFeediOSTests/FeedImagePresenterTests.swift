//
//  FeedImagePresenterTests.swift
//  EssentialFeediOSTests
//
//  Created by Alex.personal on 7/1/24.
//

import XCTest
import EssentialFeediOS
import FeedLoader

final class FeedImagePresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let image = uniqueImage()
        
        let viewModel = FeedImagePresenter.map(image)
        
        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
    }
    
    func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), url: URL(string: "www.google.com")!)
    }
    
    func anyError() -> Error {
        NSError(domain: "any error", code: 1)
    }
}
