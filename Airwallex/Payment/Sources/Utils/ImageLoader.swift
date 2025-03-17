//
//  ImageLoader.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/17.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

actor ImageLoader: DebugLoggable {
    private var dataCache = NSCache<NSURL, NSData>()
    private var taskCache = [URL: Task<Data, any Error>]()
    
    private class TaskWrapper {
        let task: Task<Void, Never>
        let imageURL: URL
        init(_ task: Task<Void, Never>, imageURL: URL) {
            self.task = task
            self.imageURL = imageURL
        }
    }
    private var viewToTaskMap = NSMapTable<UIView, TaskWrapper>(keyOptions: [.objectPointerPersonality, .weakMemory])
    
    private func requestImageData(_ imageURL: URL) async throws -> Data? {
        let keyForNSCache = imageURL as NSURL
        //  match outgoing data request
        if let task = taskCache[imageURL] {
            let data = try await task.value
            dataCache.setObject(data as NSData, forKey: keyForNSCache)
            return data
        }
        
        // creat a new task
        let newTask = Task {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            return data
        }
        taskCache[imageURL] = newTask
        do {
            let data = try await newTask.value
            dataCache.setObject(data as NSData, forKey: keyForNSCache)
            taskCache.removeValue(forKey: imageURL)
            return data
        } catch {
            taskCache.removeValue(forKey: imageURL)
            throw error
        }
    }
    
    func loadImage(_ imageURL: URL, for imageView: UIImageView) {
        // synchronously check data cache
        if let cachedData = dataCache.object(forKey: imageURL as NSURL) as Data? {
            imageView.image = UIImage(data: cachedData)
            return
        }
        // check existing task
        if let existingTask = viewToTaskMap.object(forKey: imageView) {
            guard existingTask.imageURL != imageURL else {
                // task loading the same imageURL for the same imageView already exists
                return
            }
            // loading different imageURL for the same imageView
            // cancel the previous task
            existingTask.task.cancel()
        }
        // start a new task and bind it to the view
        let newTask = Task {
            defer {
                // cleanup `viewToTaskMap`
                self.viewToTaskMap.removeObject(forKey: imageView)
            }
            do {
                guard let data = try await requestImageData(imageURL) else {
                    return
                }
                
                guard !Task.isCancelled else {
                    // if the task is cancelled, don't set image to imageView
                    return
                }
                
                Task.detached { @MainActor in
                    imageView.image = UIImage(data: data)
                }
            } catch {
                debugLog(error.localizedDescription)
            }
        }
        imageView.image = nil
        viewToTaskMap.setObject(TaskWrapper(newTask, imageURL: imageURL), forKey: imageView)
    }
}
