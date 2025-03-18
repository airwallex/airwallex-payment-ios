//
//  ImageLoader.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/17.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

actor ImageFetcher {
    private var networkTasks = [URL: Task<Data, any Error>]()
    
    fileprivate func requestImageData(_ imageURL: URL) async throws -> Data {

        //  match outgoing data request
        if let task = networkTasks[imageURL] {
            let data = try await task.value
            return data
        }
        
        // creat a new task
        let newTask = Task {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            return data
        }
        networkTasks[imageURL] = newTask
        do {
            let data = try await newTask.value
            networkTasks.removeValue(forKey: imageURL)
            return data
        } catch {
            networkTasks.removeValue(forKey: imageURL)
            throw error
        }
    }
    
    private class TaskWrapper {
        let task: Task<UIImage, Error>
        let imageURL: URL
        init(_ task: Task<UIImage, Error>, imageURL: URL) {
            self.task = task
            self.imageURL = imageURL
        }
    }
    
    enum ImageFetcherError: Error {
        case networkError(underlying: Error)
        case existingTask
        case invalidData
        case cancelled
    }
    
    private var viewTasks = NSMapTable<UIView, TaskWrapper>(keyOptions: [.objectPointerPersonality, .weakMemory])
    
    func startTask(_ imageURL: URL, for view: UIView) async throws -> UIImage {
        // check existing task
        if let existingTask = viewTasks.object(forKey: view) {
            guard existingTask.imageURL != imageURL else {
                // task loading the same imageURL for the same imageView already exists
                throw ImageFetcherError.existingTask
            }
            // loading different imageURL for the same imageView
            // cancel the previous task
            existingTask.task.cancel()
        }
        // start a new task and bind it to the view
        let newTask = Task {
            defer {
                // cleanup `viewToTaskMap`
                self.viewTasks.removeObject(forKey: view)
            }
            do {
                let data = try await requestImageData(imageURL)
                
                guard !Task.isCancelled else {
                    // if the task is cancelled, don't set image to imageView
                    throw ImageFetcherError.cancelled
                }
                
                guard let image = UIImage(data: data) else {
                    throw ImageFetcherError.invalidData
                }
                return image
            } catch {
                throw ImageFetcherError.networkError(underlying: error)
            }
        }
        
        viewTasks.setObject(
            TaskWrapper(newTask, imageURL: imageURL),
            forKey: view
        )
        return try await newTask.value
    }
}

public class ImageLoader {
    
    private let cache = NSCache<NSURL, UIImage>()
    private let fetcher = ImageFetcher()
    
    public init(){}
    
    public func cachedImage(_ imageURL: URL) -> UIImage? {
        cache.object(forKey: imageURL as NSURL)
    }
    
    public func getImage(_ imageURL: URL, for view: UIView) async throws -> UIImage {
        let key = imageURL as NSURL
        if let image = cache.object(forKey: key) {
            return image
        } else {
            let image = try await fetcher.startTask(imageURL, for: view)
            cache.setObject(image, forKey: key)
            return image
        }
    }
}

public extension UIImageView {
    func loadImage(_ imageURL: URL, imageLoader: ImageLoader, placeholder: UIImage? = nil) {
        if let image = imageLoader.cachedImage(imageURL) {
            self.image = image
        } else {
            self.image = placeholder
            Task {
                do {
                    let image = try await imageLoader.getImage(imageURL, for: self)
                    self.image = image
                } catch {
                    debugLog(error.localizedDescription)
                }
            }
        }
    }
}

