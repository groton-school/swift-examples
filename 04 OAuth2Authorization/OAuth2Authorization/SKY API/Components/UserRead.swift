//
//  User.swift
//  OAuth2Authorization
//
//  Created by Seth Battis on 3/21/24.
//

import Foundation

struct UserRead: Codable {
    let id: Int?
    let affiliation: String?
    let custom_field_one: String?
    let custom_field_two: String?
    let custom_field_three: String?
    let custom_field_four: String?
    let custom_field_five: String?
    let custom_field_six: String?
    let custom_field_seven: String?
    let custom_field_eight: String?
    let custom_field_nine: String?
    let custom_field_ten: String?
    let deceased: Bool?
    let display: String?
    let email: String?
    let email_active: Bool?
    let first_name: String?
    let gender: String?
    let gender_description: String?
    let greeting: String?
    let host_id: String?
    let last_name: String?
    let lost: Bool?
    let maiden_name: String?
    let nickname: String?
    let preferred_name: String?
    let dob: Date?
    let prefix: String?
    let suffix: String?
    let profile_pictures: ProfilePictureUrls?
    let home_languages: [HomeLanguageRead]?
}
