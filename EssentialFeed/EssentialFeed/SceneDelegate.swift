//
//  SceneDelegate.swift
//  EssentialFeed
//
//  Created by Alex.personal on 14/11/23.
//

import UIKit
import CoreData
import Combine
import FeedLoader
import EssentialFeediOS
import EssentialFeedAPI

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
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
    
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        window?.rootViewController = UINavigationController(rootViewController:  FeedUIComposer.feedComposedWith(
            loader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primary: FeedImageCacheDecorator(
                    decoratee: remoteImageLoader,
                    cache: localImageLoader),
                fallback: localImageLoader)))
        window?.makeKeyAndVisible()
    }
    
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> RemoteFeedLoader.Publisher {
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        
        let remoteFeedLoader = RemoteFeedLoader(client: httpClient, url: url)
        
        return remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
}

public extension FeedLoader {
    typealias Publisher = AnyPublisher<[FeedImage], Error>
    func loadPublisher() -> Publisher {
        Deferred {
            Future(self.load(completion:))
        }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == [FeedImage] {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch {_ in fallbackPublisher()}.eraseToAnyPublisher()
    }
}



extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnManQeueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    
    static var immediateWhenOnManQeueScheduler: ImmediateWhenOnMainQueueSchedular {
        ImmediateWhenOnMainQueueSchedular()
    }
    
    struct ImmediateWhenOnMainQueueSchedular: Scheduler {
        
        func schedule(after date: DispatchQueue.SchedulerTimeType, interval: DispatchQueue.SchedulerTimeType.Stride, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
        
        func schedule(after date: DispatchQueue.SchedulerTimeType, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }
        
        func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            guard Thread.isMainThread else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            
            action()
        }
        
        var now: DispatchQueue.SchedulerTimeType {
            DispatchQueue.main.now
        }
        
        var minimumTolerance: DispatchQueue.SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }
        
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        
    }
}
