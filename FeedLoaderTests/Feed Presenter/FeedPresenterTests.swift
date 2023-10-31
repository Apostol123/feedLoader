//
//  FeedPresenterTests.swift
//  FeedLoaderTests
//
//  Created by Alex.personal on 31/10/23.
//

import XCTest

final class Presenter {
    
    init(view: Any) {
        
    }
}

final class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        
        _ = Presenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    //MARK: - Helpers
    
    private class ViewSpy {
        let messages = [Any]()
    }

}
