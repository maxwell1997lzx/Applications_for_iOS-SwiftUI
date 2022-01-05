//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by CS193p Instructor on 4/26/21.
//  Copyright © 2021 Stanford University. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    @State private var selectedEmojis = Set<Int>()
    
    let defaultEmojiFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser(emojiFontSize: defaultEmojiFontSize)
        }
    }
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinates((0,0), in: geometry))
                )
                .gesture(doubleTapToZoom(in: geometry.size))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(2)
                } else {
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .scaleEffect(zoomScale)
                            .position(position(for: emoji, in: geometry))
                            .gesture(panEmojiGesture().simultaneously(with: removeEmojiGesture(emoji: emoji).exclusively(before: selectionGesture(emoji: emoji))))
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText,.url,.image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            .gesture(deselectAllGesture()
                        .simultaneously(with: panGesture()
                                            .simultaneously(with: zoomGesture()
                                            )
                        )
            )
            .alert(item: $alertToShow) { alertToShow in
                // return Alert
                alertToShow.alert()
            }
            .onChange(of: document.backgroundImageFetchStatus) { status in
                switch status {
                case .failed(let url):
                    showBackgroundImageFetchFailedAlert(url)
                default:
                    break
                }
            }
        }
    }
    
    @State private var alertToShow: IdentifiableAlert?
    
    private func showBackgroundImageFetchFailedAlert(_ url: URL) {
        alertToShow = IdentifiableAlert(id: "fetch failed: " + url.absoluteString, alert: {
            Alert(
                title: Text("Background Image Fetch"),
                message: Text("Couldn't load image from \(url)."),
                dismissButton: .default(Text("OK"))
            )
        })
    }
    
    // MARK: - Select
    
    private func selectEmoji(_ emoji: EmojiArtModel.Emoji) {
        selectedEmojis.insert(emoji.id)
    }
    
    private func deselectEmoji(_ emoji: EmojiArtModel.Emoji) {
        selectedEmojis.remove(emoji.id)
    }
    
    private func emojiIsSelected(_ emoji: EmojiArtModel.Emoji) -> Bool {
        selectedEmojis.contains(emoji.id)
    }
    
    private func selectionGesture(emoji: EmojiArtModel.Emoji) -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                if emojiIsSelected(emoji) {
                    deselectEmoji(emoji)
                    document.resizeEmoji(emoji, by: -10)
                } else {
                    selectEmoji(emoji)
                    document.resizeEmoji(emoji, by: 10)
                }
            }
    }
    
    private func deselectAllGesture() -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                deselectAll()
            }
    }
    
    private func deselectAll() {
        for emoji in document.emojis.filter({ emojiIsSelected($0) }) {
            document.resizeEmoji(emoji, by: -10)
        }
        selectedEmojis = []
    }
    
    // MARK: - Move selected emojis
    
    @State private var steadyStatePanEmojiOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanEmojiOffset: CGSize = CGSize.zero
    
    private func panEmojiGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanEmojiOffset) { latestDragGestureValue, gesturePanEmojiOffset, _ in
                for emoji in document.emojis.filter({ emojiIsSelected($0) }) {
                    document.moveEmoji(emoji, by: latestDragGestureValue.translation / zoomScale)
                }
            }
            .onEnded { finalDragGestureValue in
                for emoji in document.emojis.filter({ emojiIsSelected($0) }) {
                    document.moveEmoji(emoji, by: steadyStatePanEmojiOffset + (finalDragGestureValue.translation / zoomScale))
                }
            }
    }
    
    // MARK: - Delete emoji
    
    private func removeEmojiGesture(emoji: EmojiArtModel.Emoji) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                removeEmoji(emoji)
            }
    }
    
    private func removeEmoji(_ emoji: EmojiArtModel.Emoji) {
        document.removeEmoji(emoji)
    }
    
    // MARK: - Drag and Drop
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(.url(url.imageURL))
        }
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data))
                }
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(
                        String(emoji),
                        at: convertToEmojiCoordinates(location, in: geometry),
                        size: defaultEmojiFontSize / zoomScale
                    )
                }
            }
        }
        return found
    }
    
    // MARK: - Positioning/Sizing Emoji
    
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
        )
    }
    
    // MARK: - Zooming
    
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                if selectedEmojis.isEmpty {
                    gestureZoomScale = latestGestureScale
                } else {
                    document.emojis.forEach { emoji in
                        if selectedEmojis.contains(emoji.id) {
                            document.scaleEmoji(emoji, by: latestGestureScale)
                        }
                    }
                }
            }
            .onEnded { gestureScaleAtEnd in
                if selectedEmojis.isEmpty {
                    steadyStateZoomScale *= gestureScaleAtEnd
                } else {
                    document.emojis.forEach { emoji in
                        if selectedEmojis.contains(emoji.id) {
                            document.scaleEmoji(emoji, by: gestureScaleAtEnd)
                        }
                    }
                }
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0  {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    // MARK: - Panning
    
    @State private var steadyStatePanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                if selectedEmojis.isEmpty {
                    gesturePanOffset = latestDragGestureValue.translation / zoomScale
                }
            }
            .onEnded { finalDragGestureValue in
                if selectedEmojis.isEmpty {
                    steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
