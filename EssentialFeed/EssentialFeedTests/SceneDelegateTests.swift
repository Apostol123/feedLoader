//
//  SceneDelegateTests.swift
//  EssentialFeedTests
//
//  Created by Alex.personal on 5/12/23.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed


class SceneDelegateTests: XCTestCase {
    
    func test_configureWindows_setsWindowAsKeyAndVisibile() {
        let window = UIWindow()
        let sut = SceneDelegate()
        sut.window = window
        
        sut.configureWindow()
        
       
        XCTAssertFalse(window.isHidden, "Expected window to be visible")
    }
    
    func test_sceneWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topController is FeedViewController, "Expected a feed controller as atop view controller, got \(String(describing: topController)) instead")
    }
}
