//
//  ContentView.swift
//  Bootcamp_HW_3
//
//  Created by Cuma Aktaş on 25.08.2025.
//

import SwiftUI

struct BootcampHW3View: View {

    var body: some View {
        ZStack {
            BackgroundLayerView(
                Colors: [.orange, .yellow, .gray])
            VStack {
                ProfilePictureView()
                
                UserView(userName: "Cuma Aktaş")
                
                BioView(bioDescription: "iOS Developer")
                
                CardView(cardText: "Followers",
                         cardCount: 999)
                
                CardView(cardText: "Followed",
                         cardCount: 999)
                
                CardView(cardText: "Liked",
                         cardCount: 999)
                
                ButtonView(iconName: "paperplane",
                           buttonTitle: "Message",
                           buttonColor: .blue)
                
                ButtonView(iconName: "person.badge.plus",
                           buttonTitle: "Follow",
                           buttonColor: .green)
            }
            .padding()
        }
       
    }
}

#Preview {
    BootcampHW3View()
}

struct BackgroundLayerView: View {
    var Colors: [Color]
    var body: some View {
        LinearGradient (gradient: Gradient(colors: Colors), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

struct UserView: View {
    var userName: String
    var body: some View {
        Text(userName)
            .bold()
            .font(.title)
    }
}

struct BioView: View {
    var bioDescription: String
    var body: some View {
        Text(bioDescription)
            .font(.title3)
    }
}


struct ProfilePictureView: View {
    var body: some View {
        Image("userProfilePicture")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.tint)
            .clipShape(Circle())
            .frame(width: 150, height: 150)
    }
}

struct CardView: View {
    var cardText: String
    var cardCount: Int
    var body: some View {
        HStack {
            Text(cardText)
            Spacer()
            Text("\(cardCount)")
        }
        .frame(width: 150, height: 50)
    }
}

struct ButtonView: View {
    var iconName: String
    var buttonTitle: String
    var buttonColor: Color
    var body: some View {
        HStack {
            Image(systemName: iconName)
            Text(buttonTitle)
        }
        .frame(width: 150, height: 50)
        .foregroundColor(.white)
        .background(buttonColor)
        .cornerRadius(10)
    }
}
