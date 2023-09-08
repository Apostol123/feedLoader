//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Alex.personal on 8/9/23.
//

import XCTest

class FeedViewController {
    
    init(loader: FeedViewControllerTests.LoaderSpy) {
        
    }
    
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doenNotLoad() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }

}
