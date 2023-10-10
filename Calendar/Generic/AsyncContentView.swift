//
//  AsyncContentView.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 10/10/2023.
//

import SwiftUI

struct AsyncContentView<Source: LoadableObject, LoadingView: View, Content: View>: View {
    @ObservedObject var source: Source
    var loadingView: LoadingView
    var content: () -> Content
    
    init(source: Source, loadingView: LoadingView, @ViewBuilder content: @escaping () -> Content) {
        self.source = source
        self.loadingView = loadingView
        self.content = content
    }

    var body: some View {
        switch source.state {
        case .idle:
            Color.clear.onAppear(perform: source.makeRequest)
        case .loading:
            loadingView
        case .failed:
            EmptyView()
        case .loaded:
            content()
        }
    }
}

enum LoadingState {
    case idle
    case loading
    case failed(Error)
    case loaded
}

@MainActor
protocol LoadableObject: ObservableObject {
    var state: LoadingState { get }
    func makeRequest()
}

typealias DefaultProgressView = ProgressView<EmptyView, EmptyView>

extension AsyncContentView where LoadingView == DefaultProgressView {
    init(
        source: Source,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            source: source,
            loadingView: ProgressView(),
            content: content
        )
    }
}

