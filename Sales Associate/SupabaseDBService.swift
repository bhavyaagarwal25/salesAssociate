import Foundation

class SupabaseDBService {
    static let shared = SupabaseDBService()
    
    private let baseURL = "https://zfengirsvsjikrhxrfit.supabase.co/rest/v1"
    private let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmZW5naXJzdnNqaWtyaHhyZml0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI0MTg5NTIsImV4cCI6MjA5Nzk5NDk1Mn0.rk57GzYVJDkHtEH649eXekzqox0s3O3nH3u8f5KHY5M"
    
    private init() {}
    
    /// Fetches all client profiles from the Supabase database.
    func fetchProfiles() async throws -> [ClientProfile] {
        guard let url = URL(string: "\(baseURL)/client_profiles?select=*") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([ClientProfile].self, from: data)
    }
    
    /// Inserts or updates a single client profile in Supabase.
    func upsertProfile(_ profile: ClientProfile) async throws {
        guard let url = URL(string: "\(baseURL)/client_profiles") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("resolution=merge-duplicates", forHTTPHeaderField: "Prefer")
        
        let encoder = JSONEncoder()
        var dictionary = try JSONSerialization.jsonObject(with: try encoder.encode(profile)) as? [String: Any] ?? [:]
        dictionary.removeValue(forKey: "tasks")
        let jsonData = try JSONSerialization.data(withJSONObject: dictionary)
        request.httpBody = jsonData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) else {
            throw URLError(.badServerResponse)
        }
    }
    
    /// Uploads an array of client profiles in a single batch (used for initial migration).
    func uploadBatchProfiles(_ profiles: [ClientProfile]) async throws {
        guard let url = URL(string: "\(baseURL)/client_profiles") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("resolution=merge-duplicates", forHTTPHeaderField: "Prefer")
        
        let encoder = JSONEncoder()
        let dictionaries = try profiles.map { profile -> [String: Any] in
            var dict = try JSONSerialization.jsonObject(with: try encoder.encode(profile)) as? [String: Any] ?? [:]
            dict.removeValue(forKey: "tasks")
            return dict
        }
        let jsonData = try JSONSerialization.data(withJSONObject: dictionaries)
        request.httpBody = jsonData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) else {
            throw URLError(.badServerResponse)
        }
    }
}
