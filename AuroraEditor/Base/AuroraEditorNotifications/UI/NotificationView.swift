//
//  NotificationView.swift
//  
//
//  Created by Nanashi Li on 2022/07/12.
//

import SwiftUI

struct NotificationView: View {
    let data: NotificationData
    @Binding
    var isPresented: Bool
    @Binding
    var isRemoved: Bool

    var body: some View {
        VStack {
            HStack {
                data.priority.icon
                Text(data.title).lineLimit(5).font(.subheadline).foregroundColor(
                    Color.init("T1"))
                Spacer()
            }.frame(minHeight: 50).padding(.horizontal, 10)
        }.frame(maxWidth: 300).background(Color.init("sideBar.background")).cornerRadius(10)
            .onTapGesture {
                withAnimation {
                    isRemoved = true
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    withAnimation {
                        isPresented = false
                    }
                }
            }
    }
}
