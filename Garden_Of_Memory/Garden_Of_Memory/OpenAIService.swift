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
        
        // Set the timeout interval (in seconds)
        urlRequest.timeoutInterval = 50
        
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

//        let systemMessage = GPTMessage(role: "system", content: message)
        let systemMessage = GPTMessage(role: "system", content: "Reply the user sentimentally.")
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
    
//    func sendPromptToChatGPT(message: String) async throws {
//        print("\nSending prompt to ChatGPT API...")
//        let urlRequest = try generateURLRequest(httpMethod: .post, message: message)
//        
//        print("Preparing to send request...")
//        do {
//            let (data, response) = try await URLSession.shared.data(for: urlRequest)
//            print("Request sent successfully.")
//            
//            // Debugging: Print the received data
//            if let dataString = String(data: data, encoding: .utf8) {
//                print("Received Data:", dataString)
//            } else {
//                print("Error converting response data to string.")
//            }
//            
//            if let httpResponse = response as? HTTPURLResponse {
//                print("HTTP Status Code:", httpResponse.statusCode)
//            } else {
//                print("Failed to get HTTP response status code.")
//            }
//            
//            // Print a message indicating successful completion
//            print("API request completed successfully.")
//        } catch {
//            print("Error sending request:", error.localizedDescription)
//        }
//    }
    
    func sendPromptToChatGPT(message: String, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let urlRequest = try generateURLRequest(httpMethod: .post, message: message)
            print("Preparing to send request...")
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                print("API request made.")
                
                if let error = error {
                    print("Error occurred during API request:", error.localizedDescription) // Added print statement
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Unexpected response format. Expected HTTPURLResponse.") // Added print statement
                    return
                }
                
                if httpResponse.statusCode == 200, let data = data {
                    // Print the raw response data for debugging
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw Response Data:", jsonString)
                    }
                    
                    // Inspect the data before decoding
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                        print("Parsed JSON Data:", jsonData)
                    } catch {
                        print("Error parsing JSON data:", error.localizedDescription)
                    }
                    
                    do {
                        print("Decoding JSON response...")
                        let decodedResponse = try JSONDecoder().decode(ChatCompletion.self, from: data)
                        
                        // Accessing the message content of the first choice (index 0)
                        if let firstChoice = decodedResponse.choices.first {
                            let content = firstChoice.message.content
                            print("Received Data - Content:", content)
                            self.fetchResponseFromChatGPT(dataString: content, completion: completion)
                        } else {
                            print("No choices found in the decoded response.")
                            completion(.failure(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "No choices found in the decoded response."))))
                        }
                    } catch {
                        print("Error decoding JSON:", error.localizedDescription)
                        completion(.failure(error))
                    }
                } else {
                    print("Failed to receive a response from ChatGPT")
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
//    func sendPromptToChatGPT(message: String, completion: @escaping (Result<String, Error>) -> Void) {
//        do {
//            let urlRequest = try generateURLRequest(httpMethod: .post, message: message)
//            print("Preparing to send request...")
//
//            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//
//                guard let httpResponse = response as? HTTPURLResponse else {
////                    completion(.failure(APIError.invalidResponse))
//                    return
//                }
//
//                if httpResponse.statusCode == 200, let data = data, let dataString = String(data: data, encoding: .utf8) {
//                    print("Received Data:", dataString)
//
//                    // Call fetchResponseFromChatGPT with the dataString
//                    self.fetchResponseFromChatGPT(dataString: dataString, completion: completion)
//                } else {
////                    completion(.failure(APIError.invalidResponse))
//                    print("Failed to get response from ChatGPT")
//                }
//            }.resume()
//        } catch {
//            completion(.failure(error))
//        }
//    }
    
//    // Diaplay "dataString" to frontend UI
//    func fetchResponseFromChatGPT(dataString: String, completion: @escaping (Result<String, Error>) -> Void) {
//        // Here you can further process the dataString if needed before passing it to the completion handler
//        completion(.success(dataString))
//    }
    
    
    
    
    
//    // Display "dataString" to frontend UI
//    func fetchResponseFromChatGPT(dataString: String, completion: @escaping (Result<String, Error>) -> Void) {
//        // Here you can further process the dataString if needed before passing it to the completion handler
//        completion(.success(dataString))
//        print("!!! fetchResponseFromChatGPT: !!!", dataString)
//    }
    
    
    
    
    
//    // Display "dataString" to frontend UI
//    func fetchResponseFromChatGPT(dataString: String, completion: @escaping (Result<String, Error>) -> Void) {
//        // Convert the JSON data string to Data
//        guard let jsonData = dataString.data(using: .utf8) else {
////            completion(.failure(NetworkError.invalidData))
//            print("Network Error 1")
//            return
//        }
//
//        do {
//            // Decode the JSON data
//            let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: jsonData)
//            
//            // Access the first message's content
//            if let firstMessage = response.messages.first {
//                let content = firstMessage.content
//                print("Retrieved content:", content)
//                completion(.success(content))
//            } else {
////                completion(.failure(NetworkError.invalidResponse))
//                print("Network Error 2")
//            }
//        } catch {
//            print("Error decoding JSON:", error.localizedDescription)
//            completion(.failure(error))
//        }
//    }
    
    
    
    
    
    // Display "dataString" to frontend UI
    func fetchResponseFromChatGPT(dataString: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Here you can further process the dataString if needed before passing it to the completion handler
        completion(.success(dataString))
        print("!!! fetchResponseFromChatGPT: !!!", dataString)
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





//// Below is the struct to json decode the response from ChatGPT
//struct ChatCompletion: Codable {
//    let id: String
//    let object: String
//    let created: Int
//    let model: String
//    let systemFingerprint: String
//    let choices: [Choice]
//    let usage: Usage
//    
////    enum CodingKeys: String, CodingKey {
////        case id
////        case object
////        case created
////        case model
////        case systemFingerprint = "system_fingerprint"
////        case choices
////        case usage
////    }
//}
//
//struct Choice: Codable {
//    let index: Int
//    let message: Message
//    let logprobs: String? // or whatever type logprobs should be
//    let finishReason: String
//    
////    enum CodingKeys: String, CodingKey {
////        case index
////        case message
////        case logprobs
////        case finishReason = "finish_reason"
////    }
//}
//
//struct Message: Codable {
//    let role: String
//    let content: String
//}
//
//struct Usage: Codable {
//    let promptTokens: Int
//    let completionTokens: Int
//    let totalTokens: Int
//    
////    enum CodingKeys: String, CodingKey {
////        case promptTokens = "prompt_tokens"
////        case completionTokens = "completion_tokens"
////        case totalTokens = "total_tokens"
////    }
//}





// Below is the struct to json decode the response from ChatGPT
struct ChatCompletion: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let systemFingerprint: String
    let choices: [Choice]
    let usage: Usage

    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case model
        case systemFingerprint = "system_fingerprint"
        case choices
        case usage
    }
}

struct Choice: Codable {
    let index: Int
    let message: Message
    let logprobs: String? // or whatever type logprobs should be
    let finishReason: String

    enum CodingKeys: String, CodingKey {
        case index
        case message
        case logprobs
        case finishReason = "finish_reason"
    }
}

struct Message: Codable {
    let role: String
    let content: String
}

struct Usage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}
