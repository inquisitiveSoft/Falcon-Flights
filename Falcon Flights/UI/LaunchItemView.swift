//
//  LaunchItemView.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 02/05/2022.
//  This code is available under the MIT license: https://opensource.org/licenses/MIT
//

import SwiftUI

struct LaunchItemView: View {
    var item: LaunchItem
    
    var body: some View {
        VStack {
            VStack {
                VStack {
                    if let imageURL = item.imageURLs.first {
                        LoadingImage(url: imageURL) {
                            PlaceholderImage()
                        }
                    } else {
                        PlaceholderImage()
                    }
                }
                // Setting minHeight and maxHeight works, where setting the height: doesn't constrain the image.
                .frame(minHeight: 240, maxHeight: 240)
                .clipped()
            }
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadius))

            HStack {
                PatchImageView(item: item)
                
                VStack(alignment: .leading) {
                    Text(item.name).truncationMode(.tail)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                    
                    Text(localizedString(from: item.date))
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                }

                if let success = item.success {
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        successLabel(for: success)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadius))
        .clipped()
        .padding(.horizontal, .padding(2))
        .padding(.vertical, .padding(1))
    }
    
    
    private func localizedString(from date: Date) -> String {
        return DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none)
    }
    
    private func successLabel(for success: Bool) -> some View {
        VStack {
            Text(success ? "success" : "failure")
        }
        .font(.system(size: 17, weight: .bold, design: .rounded))
        .foregroundColor(color(for: success))
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .overlay(RoundedRectangle(cornerRadius: .padding(1))
                    .stroke(color(for: success), lineWidth: .strokeWidth))
        .padding(.trailing, .strokeWidth)  // An extra padding so that the stroke isn't clipped
    }
    
    func color(for success: Bool) -> Color {
        return success ? .green : .red
    }
}

/// Displays the patch image for the mission
private struct PatchImageView: View {
    var item: LaunchItem
    
    var body: some View {
        VStack {
            if let patchImageURL = item.patchImageURL {
                LoadingImage(url: patchImageURL) {
                    patchPlaceholder()
                }
                .scaledToFit()
            } else {
                patchPlaceholder()
            }
        }
        .frame(maxWidth: .padding(4), maxHeight: .padding(4), alignment: .topTrailing)
    }
    
    private func patchPlaceholder() -> some View {
        Image("diamond.inset.filled")
            .font(.system(size: 56))
            .foregroundColor(.gray.opacity(0.5))
    }

}
