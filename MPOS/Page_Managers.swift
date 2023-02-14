import SwiftUI

struct Managers: View {
    @State var showListProduct : Bool = false
    @State var showCategories : Bool = false
    @State var showAnalytics : Bool = false
    var body: some View {
        NavigationView{
            List{
                Section(header: Text("จัดการข้อมูล")) {
                    Button(action: {
                        showListProduct.toggle()
                    }, label: {
                        HStack{
                            AsyncImage(url: URL(string: "https://cdn-icons-png.flaticon.com/512/679/679922.png" )) { image in image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "shippingbox.fill")
                            }.frame(width: 30, height: 30)
                            Text("สินค้า")
                        }
                    })
                    .sheet(isPresented: $showListProduct){
                        ListProducts()
                    }
                    
                    Button(action: {
                        showCategories.toggle()
                    }, label: {
                        HStack{
                            AsyncImage(url: URL(string: "https://cdn-icons-png.flaticon.com/512/2272/2272696.png" )) { image in image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "shippingbox.circle.fill")
                            }.frame(width: 30, height: 30)
                            Text("ประเภทสินค้า")
                        }
                    })
                    .sheet(isPresented: $showCategories){
                        Categories()
                    }
                    Button(action: {
                        showAnalytics.toggle()
                    }, label: {
                        HStack{
                            AsyncImage(url: URL(string: "https://cdn-icons-png.flaticon.com/512/3153/3153391.png" )) { image in image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "bonjour")
                            }.frame(width: 30, height: 30)
                            
                            Text("การวิเคราะห์")
                        }
                        
                    }).sheet(isPresented: $showAnalytics){Analytics()}
                    
                    NavigationLink(destination: ChartView()) {
                        HStack{
                            AsyncImage(url: URL(string: "https://cdn-icons-png.flaticon.com/512/9656/9656370.png" )) { image in image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "chart.bar.doc.horizontal.fill")
                            }.frame(width: 30, height: 30)
                            
                            Text("แดชบอร์ด")
                        }
                    }
                }
            }//List
            ChartView()
        }//NavigationView
    }
}//Managers
