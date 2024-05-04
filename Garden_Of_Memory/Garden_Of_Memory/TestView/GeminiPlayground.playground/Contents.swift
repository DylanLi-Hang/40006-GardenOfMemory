
// In the Xcode Add Packages dialog, add this Swift package URL into the search bar:
// https://github.com/google/generative-ai-swift

// Add the following code to your Swift source code
import GoogleGenerativeAI

let config = GenerationConfig(
  temperature: 1,
  topP: 0.95,
  topK: 0,
  maxOutputTokens: 8192,
)

// Don't check your API key into source control!
//guard let apiKey = ProcessInfo.processInfo.environment["API_KEY"] else {
//  fatalError("Add `API_KEY` as an Environment Variable in your app's scheme.")
//}

let model = GenerativeModel(
  name: "gemini-1.0-pro",
  apiKey: "AIzaSyDVicn5jNx8tOqbgoLXBFtgWpfTnY0Fgtk",
  generationConfig: config,
  safetySettings: [
    SafetySetting(harmCategory: .harassment, threshold: .blockMediumAndAbove),
    SafetySetting(harmCategory: .hateSpeech, threshold: .blockMediumAndAbove),
    SafetySetting(harmCategory: .sexuallyExplicit, threshold: .blockMediumAndAbove),
    SafetySetting(harmCategory: .dangerousContent, threshold: .blockMediumAndAbove)
  ]
)

let chat = model.startChat(history: [
  ModelContent(role: "user", parts: "Hello! Who are you?"),
  ModelContent(role: "model", parts: "Hi there! I'm Waterdrop, your friendly companion here to listen and flow alongside your emotions. Tell me, what kind of day has it been for you?")
])

Task {
  do {
    let message = "Who are you?"
    let response = try await chat.sendMessage(message)
    print(response.text ?? "No response received")
  } catch {
    print(error)
  }
}
