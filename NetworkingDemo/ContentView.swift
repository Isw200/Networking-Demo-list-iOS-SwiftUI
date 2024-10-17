//
//  ContentView.swift
//  NetworkingDemo
//
//  Created by Isuru Ariyarathna on 2024-10-16.
//

import SwiftUI

struct DataDTO : Codable, Hashable {
    let postId: Int
    let title: String
    let body: String
    
    enum CodingKeys: String, CodingKey {
        case postId = "id"
        case title
        case body
    }
}

struct ContentView: View {
    @State var data : [DataDTO] = []
    @State var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack{
                if isLoading {
                    VStack {
                        ProgressView()
                    }
                } else {
                    List(data, id: \.postId) { item in
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)
                            Text(item.body)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("News Feed")
        }
        .refreshable {
            Task {
                await fetchData()
            }
        }
        .onAppear{
            Task {
                await fetchData()
            }
        }
    }
    
    func fetchData() async {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")
        
        guard let unwrappedUrl = url else { return }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: unwrappedUrl)
            guard let response = response as? HTTPURLResponse else {
                print("Something went wrong")
                return
            }
            
            switch response.statusCode {
            case 200..<300:
                let decodedData = try JSONDecoder().decode([DataDTO].self, from: data)
                self.data = decodedData
                
            case 400..<500:
                print("Server Error")
            default:
                print("Something went wrong")
            }
            
        } catch {
            print("Something went wrong \(error.localizedDescription)")
        }
        self.isLoading = false
    }
}

#Preview {
    ContentView()
}
