//
//  ChartView.swift
//  mPOS
//
//  Created by Palapon Thitithanaporn on 3/1/2566 BE.
//

import SwiftUI
import Charts

struct ChartView: View {
    @State var adata = [Adata]()
    @State var adetail = [AdataDetail]()
    @State var items = [Items]()
    @State var adataSum = 0.0
    @State var showHistory = false
    @State var dateNow = Date().formatted(.dateTime.day().month().year())
    var body: some View {
        VStack{
            Button(action: {
                withAnimation(.easeOut(duration: 0.7)){
                    showHistory.toggle()
                }
            }, label: {
                Text("ยอดรวม: ฿\(adata.map { $0.Asumtotal }.reduce(0, +),specifier: "%.2f")").font(.title2)
            })   .tint(.green)
                .buttonStyle(.bordered)
                .sheet(isPresented: $showHistory){
                    Analytics()
                }
        }
        
                List{
                    Section(header: Text("แดชบอร์ด")) {
                        if #available(iOS 16.0, *) {
                            ScrollView(.horizontal){
                                GroupBox ("รายงานสรุปยอดขายแยกตามสินค้า") {
                                    Chart {
                                        ForEach(Array(items.enumerated()), id: \.element) { index , i in
                                            BarMark(x: .value("\(i.Pname)", "\(i.Pname)"),
                                                    y: .value("val", adetail.filter({ $0.pname.contains(i.Pname) }).count))
                                            .foregroundStyle(by: .value("\(i.Pname)", "\(i.Pname)"))
                                            .annotation(position: .top) {
                                                if ( adetail.filter({ $0.pname.contains(i.Pname) }).count != 0){
                                                    Text("\(adetail.filter({ $0.pname.contains(i.Pname) }).count)")
                                                }
                                            }
                                        }
                                    }.frame(width: 600)
                                }
                            }
                            ScrollView(.horizontal){
                                GroupBox ("ยอดขายประจำเดือน") {
                                    Chart {
                                        ForEach(0..<12, id: \.self) { i in
                                            BarMark(
                                                x: .value("\(getMonth(value: i ))", getMonth(value: i )),
                                                y: .value("val", adetail.filter({ $0.Adate.formatted(.dateTime.month()) == "\(getMonth(value: i))" }).count
                                                         )
                                            )   .foregroundStyle(.linearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing))
                                                .annotation(position: .top) {
                                                    if (adetail.filter({ $0.Adate.formatted(.dateTime.month()) == "\(getMonth(value: i))" }).count != 0){
                                                        Text("\(adetail.filter({ $0.Adate.formatted(.dateTime.month()) == "\(getMonth(value: i))" }).count)")
                                                    }
                                                }
                                        } 
                                    }
                                }.frame(width: 700)
                            }
                            GroupBox ("ยอดขายสัปดาห์นี้") {
                                Chart {
                                    ForEach(0..<7, id: \.self) { i in
                                        BarMark(
                                            x: .value("\(getWeek(value: i ))", getWeek(value: i )),
                                            y: .value("val", adetail.filter({ $0.Adate.formatted(.dateTime.weekday()) == "\(getWeek(value: i))" }).count
                                                     )
                                        )   .foregroundStyle(by: .value("\(getWeek(value: i ))", "\(getWeek(value: i ))"))
                                            .annotation(position: .top) {
                                                if ( adetail.filter({ $0.Adate.formatted(.dateTime.weekday()) == "\(getWeek(value: i))" }).count != 0){
                                                    Text("\(adetail.filter({ $0.Adate.formatted(.dateTime.weekday()) == "\(getWeek(value: i))" }).count)")
                                                }
                                            }
                                    } 
                                }
                            }
                        }  else {
                            Text("ios 16 only")
                        }
                    }//Section
                    .headerProminence(.increased)
                }//List
        .onAppear {
            getData()
        }
    }
        func getMonth(value: Int) -> String {
            let month = Calendar.current.date(byAdding: .month, value: value, to: .distantFuture)!
            return month.formatted(.dateTime.month())
        }
    func getWeek(value: Int) -> String {
        let month = Calendar.current.date(byAdding: .weekday, value: value, to: .distantFuture)!
        return month.formatted(.dateTime.weekday())
    }
        func getData() {
            if let encodedData = UserDefaults.standard.data(forKey: "Bills") {
                do {
                    items = try PropertyListDecoder().decode([Items].self , from: encodedData)
                } catch let error as NSError {
                    NSLog("Unable to decode: error = \(error.localizedDescription)")
                }
            }
            if let encodedData = UserDefaults.standard.data(forKey: "adetail") {
                do {
                    adetail = try PropertyListDecoder().decode([AdataDetail].self , from: encodedData)
                } catch let error as NSError {
                    NSLog("Unable to decode: error = \(error.localizedDescription)")
                }
            }
            if let encodedData = UserDefaults.standard.data(forKey: "adata") {
                do {
                    adata = try PropertyListDecoder().decode([Adata].self , from: encodedData)
                } catch let error as NSError {
                    NSLog("Unable to decode: error = \(error.localizedDescription)")
                }
            }
        }
}

