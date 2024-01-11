//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Alex.personal on 10/1/24.
//

import XCTest
@testable import FeedLoader
@testable import EssentialFeediOS

final class ImageCommentsSnapshotTests: XCTestCase {

    func test_FeedWithContent() {
        let sut = makeSUT()
        
        sut.display(comments())
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
       
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyBoard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyBoard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func comments() -> [CellController] {
        comments().map({CellController($0)})
    }
    
    private func comments() -> [ImageCommentCellController] {
        return [ ImageCommentCellController(
            model: ImageCommentViewModel(
                message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                date: "1000 years ago",
                username: "a long long username")
            ),
                 ImageCommentCellController(
                    model: ImageCommentViewModel(
                message: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                date: "10 days ago",
                username: "a username")
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                message: "Nice",
                date: "1 hour ago",
                username: "a username")
            )
            
        ]
    }
}
