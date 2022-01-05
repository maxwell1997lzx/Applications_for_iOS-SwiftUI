//
//  ThemeEditor.swift
//  Memorize
//
//  Created by macbook on 17/09/2021.
//

import SwiftUI

struct ThemeEditor: View {
    
    @Binding var theme: Theme
    @Environment(\.presentationMode) var presentationMode
    @State private var pickedColor: Color = Color.black
    
    var body: some View {
        NavigationView {
            Form {
                nameSection
                colorPicker
                numberOfCardsPicker
                addEmojisSection
                removeEmojiSection
            }
            .frame(minWidth: 300, minHeight: 350)
            .navigationTitle("Edit \(theme.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if presentationMode.wrappedValue.isPresented,
                       UIDevice.current.userInterfaceIdiom != .pad {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        
    }
    
    var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Name", text: $theme.name)
        }
    }
    
    var numberOfCardsPicker: some View {
        HStack {
            Text("Number of pairs: \(theme.numberOfPairs)")
            Spacer()
            Stepper("", value: $theme.numberOfPairs, in: 0...theme.emojis.count)
        }
    }
    
    var colorPicker: some View {
        ColorPicker("Select a color for the theme", selection: $pickedColor)
            .onChange(of: pickedColor) { value in
            theme.color = RGBAColor(color: value)
        }
            .onAppear {
                pickedColor = Color(rgbaColor: theme.color)
            }
    }
    
    @State private var emojisToAdd = ""
    
    var addEmojisSection: some View {
        Section(header: Text("Add Emojis")) {
            TextField("", text: $emojisToAdd)
                .onChange(of: emojisToAdd) { emojis in
                    addEmojis(emojis)
                }
        }
    }
    
    func addEmojis(_ emojis: String) {
        withAnimation {
            emojis.forEach { emoji in
                if !theme.emojis.contains(String(emoji)) {
                    theme.emojis.append(String(emoji))
                }
            }
        }
    }
    
    var removeEmojiSection: some View {
        Section(header: Text("Remove Emoji")) {
            let emojis = theme.emojis.map { String($0) }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                theme.emojis.removeAll(where: { String($0) == emoji })
                            }
                        }
                }
            }
            .font(.system(size: 40))
        }
    }
}

struct ThemeEditor_Previews: PreviewProvider {
    static var previews: some View {
        ThemeEditor(theme: .constant(ThemeStore(named: "Preview").theme(at: 2)))
            .previewLayout(.fixed(width: 300, height: 600))
    }
}
