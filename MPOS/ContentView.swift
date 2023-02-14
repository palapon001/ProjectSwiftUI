import SwiftUI

struct ContentView: View {
    var body: some View {
        //VStack{
            TabView{
                List_Order()
                    .background(.bar)
                    .tabItem {
                     Label("สินค้า", systemImage: "shippingbox.fill")
                    }//.background(.white)
                Managers()
                    .tabItem {
                        Label("จัดการสินค้า", systemImage: "shippingbox.circle.fill")
                    }
                Settings()
                    .tabItem {
                        Label("ตั้งค่า", systemImage: "gear")
                    }
            }
            .accentColor(.primary)
                .onAppear() {
                    UITabBar.appearance().backgroundColor = .clear
                }
        //}
    }
}
