//
//  StravaActivityManager.swift
//  Strive Cycling
//
//  Created by Rob Pee on 6/20/25.
//

import Foundation

struct StravaActivity: Identifiable {
    let id: String
    let name: String
    let type: String
    let distance: Double
    let duration: Double
    let startDate: Date
    let calories: Double?
    let averageHeartRate: Double?
    let averagePower: Double?
}

final class StravaActivityManager {
    static let shared = StravaActivityManager()

    private let baseURL = "https://www.strava.com/api/v3"

    func fetchRecentActivities() {
        ensureValidToken { token in
            guard let token = token else {
                print("Missing or invalid access token")
                return
            }

            let urlString = "\(self.baseURL)/athlete/activities?per_page=5"
            guard let url = URL(string: urlString) else {
                print("Invalid activities URL")
                return
            }

            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data returned")
                    return
                }

                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        for dict in jsonArray {
                            if let activity = self.parseActivity(from: dict) {
                                print("Activity: \(activity.name), Distance: \(activity.distance), Date: \(activity.startDate)")
                            }
                        }
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                }
            }.resume()
        }
    }

    private func ensureValidToken(completion: @escaping (String?) -> Void) {
        guard let expiration = StravaAuthManager.shared.tokenExpiration,
              let token = StravaAuthManager.shared.accessToken else {
            completion(nil)
            return
        }

        if Date() < expiration {
            completion(token)
        } else {
            StravaAuthManager.shared.refreshAccessToken { success in
                completion(success ? StravaAuthManager.shared.accessToken : nil)
            }
        }
    }

    private func parseActivity(from dict: [String: Any]) -> StravaActivity? {
        guard
            let id = dict["id"] as? Int,
            let name = dict["name"] as? String,
            let type = dict["type"] as? String,
            let distance = dict["distance"] as? Double,
            let duration = dict["elapsed_time"] as? Double,
            let startDateStr = dict["start_date"] as? String,
            let startDate = ISO8601DateFormatter().date(from: startDateStr)
        else {
            return nil
        }

        return StravaActivity(
            id: String(id),
            name: name,
            type: type,
            distance: distance,
            duration: duration,
            startDate: startDate,
            calories: dict["calories"] as? Double,
            averageHeartRate: dict["average_heartrate"] as? Double,
            averagePower: dict["average_watts"] as? Double
        )
    }
}
