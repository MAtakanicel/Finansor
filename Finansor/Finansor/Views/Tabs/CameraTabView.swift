//
//  CameraTabView.swift
//  Finansor
//
//  Created by Atakan İçel on 17.04.2025.
//

import SwiftUI

struct CameraTabView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {

       ZStack{
           AppColors.backgroundDark.edgesIgnoringSafeArea(.all)
           VStack{
               Text("Elbet bir gün").padding(50)
           }
        }
    }
}

#Preview {
    CameraTabView()
}
