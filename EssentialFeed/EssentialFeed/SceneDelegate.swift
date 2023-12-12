//
//  SceneDelegate.swift
//  EssentialFeed
//
//  Created by Alex.personal on 14/11/23.
//

import UIKit
import CoreData
import FeedLoader
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store-sqlite")
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: localStoreURL)
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache(completion: {_ in })
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        configureWindow()
    }
    
    func configureWindow() {
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        let remoteClient = httpClient
        let remoteFeedLoader = RemoteFeedLoader(client: remoteClient, url: url)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
    
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        window?.rootViewController = UINavigationController(rootViewController:  FeedUIComposer.feedComposedWith(
            loader: FeedLoaderWithFallbackComposite(
                primary: FeedloaderCacheDecorator(
                    decoratee: remoteFeedLoader,
                    cache: localFeedLoader),
                fallback: localFeedLoader),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primary: FeedImageCacheDecorator(
                    decoratee: remoteImageLoader,
                    cache: localImageLoader),
                fallback: localImageLoader)))
    }
}

