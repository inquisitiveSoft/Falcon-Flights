//
//  ListView.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 28/04/2022.
//

import SwiftUI

struct FalconListView: View {
    @EnvironmentObject var flightManager: FlightManager
    @ObservedObject var dataSource: LaunchesDataSource
    
    var body: some View {
        VStack {
            if let launches = dataSource.launches {
                ScrollView {
                    ForEach(launches.items) { (item) in
                        LaunchListViewItem(item: item)
                    }
                    
                    // Show a loading indicator when loading the next page of data
                    VStack {
                        if dataSource.isLoading {
                            Text("Loading")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                        } else {
                            Button(action: {
                                dataSource.loadNext()
                            }, label: {
                                VStack(alignment: .center) {
                                    HStack {
                                        Text("Load Next")
                                        Spacer().frame(width: .padding(1))
                                        Image(systemName: "chevron.down")
                                    }
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .padding(.padding(1))
                                }
                            })
                        }
                    }
                    .frame(height: .padding(4))
                    .padding(.bottom, .padding(2))
                }
            } else if dataSource.isLoading {
                LoadingView()
            }
        }
        .onAppear {
            dataSource.loadNext()
        }
    }

}

struct LaunchListViewItem: View {
    var item: RocketItem
    
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
                VStack(alignment: .leading) {
                    Text(item.name).truncationMode(.tail)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                    
                    Text(localizedString(from: item.date))
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                }

                Spacer()
                
                VStack(alignment: .trailing) {
                    successLabel(for: item)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadius))
        .clipped()
        .padding(.horizontal, .padding(2))
        .padding(.bottom, .padding(2))
    }
    
    
    private func localizedString(from date: Date) -> String {
        return DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none)
    }
    
    private func successLabel(for item: RocketItem) -> some View {
        VStack {
            if item.success {
                Text("Success")
                    .foregroundColor(.green)
            } else {
                Text("Failure")
                    .foregroundColor(.red)
            }
        }
        .font(.system(size: 17, weight: .bold, design: .rounded))
    }
}

/// Shows a loading indicator
struct LoadingView: View {
    
    var body: some View {
        if #available(iOS 14.0, *) {
            ProgressView()
        } else {
            // Sorry iOS 13.0 users
            Text("<Imagine a loading spinner here>")
        }
    }
    
}
