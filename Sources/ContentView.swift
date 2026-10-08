import SwiftUI

struct ContentView: View {
    @State private var score = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Score: \(score)")
                .font(.title)
                .padding()
            
            Button(action: {
                score += 1
            }) {
                Text("Increment")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Button(action: {
                score = 0
            }) {
                Text("Reset to zero")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
