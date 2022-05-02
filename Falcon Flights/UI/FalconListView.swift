//
//  ListView.swift
//  Falcon Flights
//
//  Created by Harry Jordan on 28/04/2022.
//  This code is available under the MIT license: https://opensource.org/licenses/MIT
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
                        LaunchItemView(item: item)
                    }
                    
                    // Show a loading indicator when loading the next page of data
                    VStack {
                        if dataSource.isLoading {
                            Text("loading")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                        } else if dataSource.launches == nil || dataSource.launches?.next != nil {
                            if dataSource.lastRequestFailed {
                                Text("unable-to-connect")
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .padding(.padding(1))
                            }
                            
                            // Loads the next page when you scroll to the bottom
                            Button {
                                dataSource.loadNext()
                            } label: {
                                VStack(alignment: .center) {
                                    HStack {
                                        Text("load-more")
                                        Spacer().frame(width: .padding(1))
                                        Image(systemName: "chevron.down")
                                    }
                                }
                            }
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .padding(.padding(1))
                        }
                    }
                    .frame(height: .padding(4))
                    .padding(.bottom, .padding(2))
                }
            } else if dataSource.isLoading {
                LoadingView()
            } else if dataSource.lastRequestFailed {
                MainReloadPrompt(dataSource: dataSource)
            }
        }
        .onAppear {
            dataSource.loadNext()
        }
    }

}

struct MainReloadPrompt: View {
    @ObservedObject var dataSource: LaunchesDataSource
    
    var body: some View {
        VStack {
            Text("unable-to-connect")
                .font(.system(size: 20, weight: .regular, design: .rounded))
            
            Spacer().frame(height: .padding(1))
            
            Button {
                dataSource.loadNext()
            } label: {
                Text("retry")
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(.blue)
        }
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
