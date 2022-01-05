//
//  MemoryGameManager.swift
//  Memorize
//
//  Created by macbook on 15/09/2021.
//

import SwiftUI

struct MemoryGameManager: View {
    @EnvironmentObject var store: ThemeStore
    
    @State private var games: Dictionary<Int, EmojiMemoryGame> = [:]
    @State private var themeToEdit: Theme?
    @State private var showingThemeEditorPopover = false
    @State private var editMode: EditMode = .inactive
    
    // a Binding to a PresentationMode
    // which lets us dismiss() ourselves if we are isPresented
    @Environment(\.presentationMode) var presentationMode
    
    // we inject a Binding to this in the environment for the List and EditButton
    // using the \.editMode in EnvironmentValues
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.themes) { theme in
                    NavigationLink(destination: EmojiMemoryGameView(game: getGame(theme: theme))) {
                        VStack(alignment: .leading) {
                            Text("\(theme.name): \(theme.numberOfPairs * 2) cards")
                                .foregroundColor(Color(rgbaColor: theme.color))
                            Text(theme.emojis.compactMap { $0 as String }.joined())
                        }
                        .gesture(editMode == .active ? navigationLinkTap(theme: theme) : nil)
                        .popover(item: $themeToEdit) { theme in
                            ThemeEditor(theme: $store.themes[theme])
                        }
                    }
                }
                .onDelete { indexSet in
                    store.themes.remove(atOffsets: indexSet)
                }
                .onMove { indexSet, newOffset in
                    store.themes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationTitle("Manage Themes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem { EditButton() }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{
                        // TODO: Create new theme
                        themeToEdit = store.createNewTheme()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .onChange(of: themeToEdit, perform: { _ in
                updateGames()
            })
        }
    }
    
    private func navigationLinkTap(theme: Theme) -> some Gesture {
        TapGesture().onEnded {
            themeToEdit = theme
        }
    }
    
    
    
    // MARK: - Functions
    
    private func getGame(theme: Theme) -> EmojiMemoryGame {
        if let game = games[theme.id] {
            return game
        } else {
            let game = EmojiMemoryGame(theme: theme)
            games[theme.id] = game
            return game
        }
    }
    
    private func updateGames() {
        for theme in store.themes {
            if games[theme.id] == nil {
                games[theme.id] = EmojiMemoryGame(theme: theme)
            }
            else {
                // Replace old theme with the new one if needed
                if !(games[theme.id]!.theme == theme) {
                    games[theme.id]!.theme = theme
                }
            }
        }
    }
    
}

struct MemoryGameManager_Previews: PreviewProvider {
    static var previews: some View {
        MemoryGameManager()
            .previewDevice("iPhone 7")
            .environmentObject(ThemeStore(named: "Preview"))
            .preferredColorScheme(.light)
    }
}
