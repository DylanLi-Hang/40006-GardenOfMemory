//
//  OpenAIService.swift
//  Garden_Of_Memory
//
//  Created by Grace on 10/4/2024.
//

import Foundation

enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
}

class OpenAIService {
    
    static let shared = OpenAIService()
    
    private init () {}

    private func generateURLRequest(httpMethod: HTTPMethod, message: String) throws -> URLRequest {
        print("\nGenerating URL request...")
                    
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw URLError(.badURL)
        }
        
        print("URL created:", url.absoluteString)
        
        var urlRequest = URLRequest(url: url)
        
        // Method
        urlRequest.httpMethod = httpMethod.rawValue
        print("HTTP Method set:", httpMethod.rawValue)
        
        // Header
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(Secrets.apiKey)", forHTTPHeaderField: "Authorization")
        print("Headers added:", urlRequest.allHTTPHeaderFields ?? "No headers")

        // Body
        struct GPTMessage: Encodable {
            let role: String
            let content: String
        }

        let systemMessage = GPTMessage(role: "system", content: "You are a helpful assistant.")
        let userMessage = GPTMessage(role: "user", content: message)

        struct GPTChatPayload: Encodable {
            let model: String
            let messages: [GPTMessage]
            let max_tokens: Int
            let temperature: Double
            let top_p: Double
        }

        let payload = GPTChatPayload(model: "gpt-3.5-turbo", messages: [systemMessage, userMessage], max_tokens: 50, temperature: 0.7, top_p: 1.0) // "max_tokens" refers to the maximum number of tokens (words) that OpenAI API should generate in its response
        
        do {
            let jsonData = try JSONEncoder().encode(payload)
            urlRequest.httpBody = jsonData
            // Print success message
            print("HTTP Body set")
            print("URL request generated successfully.\n")
        } catch {
            throw error
        }

        return urlRequest
    }
    
    func sendPromptToChatGPT(message: String) async throws {
        print("\nSending prompt to ChatGPT API...")
        let urlRequest = try generateURLRequest(httpMethod: .post, message: message)
        
        print("Preparing to send request...")
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            print("Request sent successfully.")
            
            // Debugging: Print the received data
            if let dataString = String(data: data, encoding: .utf8) {
                print("Received Data:", dataString)
                
                // diaplay "dataString" to frontend UI
            } else {
                print("Error converting response data to string.")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code:", httpResponse.statusCode)
            } else {
                print("Failed to get HTTP response status code.")
            }
            
            // Print a message indicating successful completion
            print("API request completed successfully.")
        } catch {
            print("Error sending request:", error.localizedDescription)
        }
    }
        
}

struct GPTChatPayload: Encodable {
    let model: String
    let messages: [GPTMessage]
    let functions: [GPTFunction]
}

struct GPTMessage: Encodable {
    let role: String
    let content: String
}

struct GPTFunction: Encodable {
    let name: String
    let description: String
    let parameters: GPTFunctionParam
}

struct GPTFunctionParam: Encodable {
    let type: String
    let properties: [String: GPTFunctionProperty]?
    let required: [String]?
}

struct GPTFunctionProperty: Encodable {
    let type: String
    let description: String
}
