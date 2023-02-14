import SwiftUI

struct typeProducts : Identifiable, Codable,Hashable {
    let id: UUID    
    var tpname: String
    
    init(tpname : String) {
        id = UUID()
        self.tpname = tpname
    }
}

struct Categories: View {
    @State var tpname : String = ""
    @State var tp = [typeProducts]()
    @State private var text = ""
    @State private var search: [typeProducts] = []
    
    var body: some View {
        NavigationView {
            List{
                Section(header:Text ("ประเภท")) {
                    TextField ("ชื่อประเภทสินค้า", text: $tpname)
                    Button(action: {
                        tp.append(typeProducts(tpname: tpname))
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(tp), forKey: "tp")
                    }) {
                        Text("เพิ่มประเภทสินค้า")
                    }.disabled(self.tpname.isEmpty)
                }
                Section(header: Text("รายการประเภทสินค้า")) {
                    ForEach(text == "" ?  Array(tp.enumerated()) : Array(search.enumerated()) , id: \.element) { index , i in
                        NavigationLink(destination : TpDetail(tpname: "\(i.tpname)", index: index, tp: tp)){
                            Text("\(i.tpname)")
                        }
                    }
                    .onDelete(perform: delete)
                    .onMove(perform: move)
                }
            }
            .onAppear {
                if let encodedData = UserDefaults.standard.data(forKey: "tp") {
                    do {
                        tp = try PropertyListDecoder().decode([typeProducts].self , from: encodedData)
                    } catch let error as NSError {
                        NSLog("Unable to decode: error = \(error.localizedDescription)")
                    }
                }
            }
            .onChange(of: text) { searchValue in
                search = tp.filter { $0.tpname.contains(searchValue)}
            }
            .toolbar {
                EditButton()
            }
            .searchable(text: $text)
            .navigationBarTitle("ประเภทสินค้า")
        }
    }
    
    func delete(at offsets: IndexSet) {
        tp.remove(atOffsets: offsets)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(tp), forKey: "tp")
    }
    
    func move(from source: IndexSet, to destination: Int) {
        tp.move(fromOffsets: source, toOffset: destination)
    }
}

struct TpDetail: View {
    @State var tpname : String = ""
    @State var index = 0
    @State var tp = [typeProducts]()
    var body: some View {
        Form{
            Section(header:Text ("สินค้า")) {
                TextField ("ชื่อ ประเภทสินค้า", text: $tpname)
            }
            Button(action: {
                print(index)
                tp.remove(at: index)
                tp.insert(typeProducts(tpname: tpname), at: index )
                UserDefaults.standard.set(try? PropertyListEncoder().encode(tp), forKey: "tp")
            }, label: {
                Text("edit")
            })
        }
    }
    
}
