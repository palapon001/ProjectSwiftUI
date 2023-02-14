import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    
    @State private var isEditing = false
    
    var body: some View {
        HStack{
            HStack {
                Image(systemName: "magnifyingglass").opacity(0.2)
                TextField("ค้นหา", text: $text)
            }
            .padding(7)
            .padding(.horizontal, 25)
                .background(.bar)
                .cornerRadius(8)
                .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
                .background(
                    Rectangle()
                        .fill(.primary)
                        .cornerRadius(10)
                ).padding(.init(top: 0, leading: 5, bottom: 0, trailing: 5))
                .onChange(of: text) { _ in
                if text.isEmpty  {
                    //self.isEditing = true
                }else{
                    withAnimation(.easeOut(duration:0.3)){
                        self.isEditing = true
                    }
                }
            }
                .onTapGesture {
                    withAnimation(.easeOut(duration:0.3)){
                        self.isEditing = true
                    }
                }
        if isEditing {
            Button(action: {
                withAnimation(.easeOut(duration:0.3)){
                    self.isEditing = false
                    self.text = ""
                }
            }) {
                Text("ยกเลิก")
                    .foregroundColor(.white)
                    .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
                    .background(
                        Rectangle()
                            .fill(.red)
                            .cornerRadius(10)
                            .shadow(color: Color.gray
                                .opacity(0.9),radius: 3,x: 0,y: 0)
                    )
            }
            .padding(.trailing, 10)
        }
        }
    }
}
