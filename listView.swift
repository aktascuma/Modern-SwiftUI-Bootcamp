//
//  ContentView.swift
//  Bootcamp_HW_5
//
//  Created by Cuma Aktaş on 6.09.2025.
//

import SwiftUI

struct listView: View {
    
    @State private var bgColor: Color = .white
    
    @State private var buyItems: [Items] = [
        Items(text: "Screwdriver", icon: "screwdriver"),
        Items(text: "Fork&Knife", icon: "fork.knife"),
        Items(text: "Scanner", icon: "scanner"),
        Items(text: "Printer", icon: "printer"),
        Items(text: "Airtag", icon: "airtag"),
        Items(text: "Mac Pro", icon: "macpro.gen1"),
        Items(text: "iPod", icon: "ipod"),
        Items(text: "iPhone", icon: "iphone"),
        Items(text: "iPad", icon: "ipad"),
        Items(text: "Vision Pro", icon: "vision.pro")
    ]
    @State private var sellItems: [Items] = [
        Items(text: "Apple Pencil", icon: "applepencil"),
        Items(text: "Magic Mouse", icon: "magicmouse"),
        Items(text: "Apple Watch", icon: "applewatch"),
        Items(text: "AirPods Max", icon: "airpods.max"),
        Items(text: "AirPods Pro", icon: "earbuds.case.fill"),
        Items(text: "Beats", icon: "beats.earphones"),
        Items(text: "HomePod Mini", icon: "homepodmini"),
        Items(text: "Apple TV", icon: "appletv"),
        Items(text: "TV", icon: "tv"),
        Items(text: "Game Controller", icon: "gamecontroller")
    ]
    var body: some View {
        NavigationStack {
            List {
                Section (header: Text("Buy")){
                    ForEach(buyItems) { item in
                        NavigationLink(item.text, destination: DetailView(value: item.text, icon: item.icon))
                    }
                    .onDelete { indexSet in
                        buyItems.remove(atOffsets: indexSet)
                    }
                    .onMove { indices, newOffset in
                        buyItems.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                Section (header: Text("Sell")){
                    ForEach(sellItems) { item in
                        NavigationLink(item.text, destination: DetailView(value: item.text, icon: item.icon))
                    }
                    .onDelete { indexSet in
                        sellItems.remove(atOffsets: indexSet)
                    }
                    .onMove { indices, newOffset in
                        sellItems.move(fromOffsets: indices, toOffset: newOffset)
                    }
                    
                }
                
            }
            .toolbar {
                EditButton()
            }
            .scrollContentBackground(.hidden)
            .background(bgColor.ignoresSafeArea())
        }
        .onAppear {
                    let red = Double.random(in: 0...1)
                    let green = Double.random(in: 0...1)
                    let blue = Double.random(in: 0...1)
                    bgColor = Color(red: red, green: green, blue: blue)
                }
    }
}

#Preview {
    listView()
}

struct DetailView: View {
    var value: String
    var icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
            Text(value)
        }.font(.largeTitle)
    }
}

struct Items: Identifiable {
    var id: UUID = UUID()
    var text: String
    var icon: String
}

