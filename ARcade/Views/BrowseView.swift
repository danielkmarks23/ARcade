//
//  BrowseView.swift
//  ARcade
//
//  Created by Daniel Marks on 25/02/2022.
//

import SwiftUI

struct BrowseView: View {
    
    @EnvironmentObject var modelsManager: ModelsManager
    
    @Binding var isBrowseActive: Bool
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    RecentsGrid(isBrowseActive: $isBrowseActive)
                    
                    ForEach(ModelCategory.allCases, id: \.self) { category in
                        
                        if let modelsByCategory = modelsManager.get(category: category), modelsByCategory.count > 0 {
                            HorizontalGrid(title: category.label, items: modelsByCategory, isBrowseActive: $isBrowseActive)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Browse"), displayMode: .large)
            .navigationBarItems(trailing:
                Button {
                    isBrowseActive.toggle()
                } label: {
                    Text("Done")
                        .bold()
                        .foregroundColor(Color(.systemGray))
                }
            )
        }
    }
}

struct HorizontalGrid: View {
    
    var title: String
    var items: [Model]
    @EnvironmentObject var placementSettings: PlacementManager
    @Binding var isBrowseActive: Bool
    
    // MARK: Private Properties
    
    private let gridItemLayout = [GridItem(.fixed(150))]
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Divider()
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            
            Text(title)
                .font(.title2)
                .bold()
                .padding(.leading, 22)
                .padding(.top, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: gridItemLayout, spacing: 30) {
                    
                    ForEach(0..<items.count) { index in
                        
                        let model = items[index]
                        
                        ItemButton(model: model) {
                            model.asyncLoadModelEntity { success, error in
                                if success {
                                    placementSettings.selectedModel = model
                                }
                            }
                            placementSettings.selectedModel = model
                            Logger.log(type: .info, message: model.name)
                            isBrowseActive.toggle()
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
            }
        }
    }
}

struct RecentsGrid: View {
    
    @EnvironmentObject var placementSettings: PlacementManager
    @Binding var isBrowseActive: Bool
    
    var body: some View {
        if !placementSettings.recentlyPlaced.isEmpty {
            HorizontalGrid(title: "Recents", items: getRecentsUniqueOrdered(), isBrowseActive: $isBrowseActive)
        }
    }
    
    func getRecentsUniqueOrdered() -> [Model] {
        var recentsUniqueOrderedArray: [Model] = []
        
        for model in placementSettings.recentlyPlaced.reversed() {
            
            if recentsUniqueOrderedArray.firstIndex(of: model) == nil {
                recentsUniqueOrderedArray.append(model)
            }
        }
        
        return recentsUniqueOrderedArray
    }
}

struct ItemButton: View {
    let model: Model
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
            Logger.log(type: .debug, message: "\(model.name) tapped")
        }) {
            Image(model.name.isEmpty ? "photo" : model.name)
                .resizable()
                .frame(width: 150, height: 150)
                .aspectRatio(1/1, contentMode: .fit)
                .background(Color(UIColor.secondarySystemFill))
                .cornerRadius(8.0)
        }
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView(isBrowseActive: .constant(false))
    }
}
