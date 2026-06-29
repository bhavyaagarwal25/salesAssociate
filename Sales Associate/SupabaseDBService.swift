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
    
    /// Checks if a sales associate email is registered in the database User table.
    func isUserRegistered(email: String) async -> Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let url = URL(string: "\(baseURL)/User?Email=eq.\(cleanEmail)") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return false
            }
            
            if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                return !jsonArray.isEmpty
            }
            return false
        } catch {
            return false
        }
    }
    
    /// Fetches the user profile from the database User table by email.
    func fetchUserProfile(email: String) async throws -> DBUser? {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let url = URL(string: "\(baseURL)/User?Email=eq.\(cleanEmail)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let users = try JSONDecoder().decode([DBUser].self, from: data)
        return users.first
    }
    
    /// Updates the user's active status and sets authUserID in the User table in Supabase.
    func activateUser(email: String, authUserID: String, accessToken: String) async throws {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let url = URL(string: "\(baseURL)/User?Email=eq.\(cleanEmail)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        
        let body: [String: Any] = [
            "isActive": true,
            "authUserID": authUserID
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? ""
        print("activateUser Status: \(httpResponse.statusCode), Response: \(responseString)")
        
        if !(httpResponse.statusCode == 200 || httpResponse.statusCode == 201 || httpResponse.statusCode == 204) {
            throw URLError(.badServerResponse)
        }
        
        if responseString.trimmingCharacters(in: .whitespacesAndNewlines) == "[]" {
            throw NSError(
                domain: "SupabaseDBService",
                code: 403,
                userInfo: [NSLocalizedDescriptionKey: "Update blocked by Row Level Security (RLS) policy. 0 rows updated."]
            )
        }
    }
}

struct DBUser: Codable {
    let id: String
    let firstName: String?
    let lastName: String?
    let email: String?
    let phoneNumber: String?
    let userRole: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "First Name"
        case lastName = "Last Name"
        case email = "Email"
        case phoneNumber = "Phone Number"
        case userRole = "User Role"
    }
}

