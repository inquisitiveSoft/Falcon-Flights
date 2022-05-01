//
//  ImageViews.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 01/05/2022.
//

import SwiftUI
import Combine

/// A shared URLSession which uses caching
extension URLSession {
    
    static let cachingURLSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        
        let session = URLSession(configuration: config)
        return session
    }()

}

/// Loads an image, similar to Apple's AsyncImage, which isn't currently available
struct LoadingImage<Content>: View where Content: View {
    var url: URL
    var placeholder: () -> Content
        
    @State private var isLoading: Bool = false
    @State private var downloadedImage: UIImage?
    @State private var cancellable = Set<AnyCancellable>()

    init(url: URL, @ViewBuilder placeholder: @escaping () -> Content) {
        self.url = url
        self.placeholder = placeholder
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            if let downloadedImage = downloadedImage {
                Image(uiImage: downloadedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .layoutPriority(-1)
            } else {
                placeholder()
                
                if isLoading {
                    LoadingView()
                }
            }
        }
        .onAppear {
            loadImage(from: url)
        }
    }
    
    func loadImage(from url: URL) {
        withAnimation {
            isLoading = true
        }
        
        // Note that this doesn't attempt to retry if the request fails
        // which you'd expect in a production app
        URLSession.cachingURLSession.dataTaskPublisher(for: url)
            .sink { completionResult in
                withAnimation {
                    isLoading = false
                }
            } receiveValue: { (data: Data, _) in
                withAnimation {
                    downloadedImage = UIImage(data: data)
                }
            }
            .store(in: &cancellable)
    }
    
}


struct PlaceholderImage: View {
    
    var body: some View {
        ZStack {
            Color(UIColor(hue: 0, saturation: 0, brightness: 0.8, alpha: 1))
            
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 64))
                .foregroundColor(Color(UIColor(hue: 0, saturation: 0, brightness: 0.7, alpha: 1)))
        }
    }
    
}
