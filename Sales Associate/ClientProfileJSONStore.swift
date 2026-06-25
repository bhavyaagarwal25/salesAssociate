import Foundation

enum ClientProfileJSONStore {
    private static let fileName = "client-profiles.json"

    static func loadProfiles() -> [ClientProfile] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            let profiles = ClientProfile.sampleProfiles
            saveProfiles(profiles)
            return profiles
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([ClientProfile].self, from: data)
        } catch {
            return ClientProfile.sampleProfiles
        }
    }

    static func saveProfiles(_ profiles: [ClientProfile]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(profiles)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            #if DEBUG
            print("Failed to save client profiles JSON: \(error)")
            #endif
        }
    }

    static var fileURL: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent(fileName)
    }
}
