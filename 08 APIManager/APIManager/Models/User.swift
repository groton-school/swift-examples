//
//  User.swift
//  APIManager
//
//  Created by Seth Battis on 4/7/24.
//

import Foundation

struct User: Codable {
    var id: Int32?
    var custom_field_one: String?
    var custom_field_two: String?
    var custom_field_three: String?
    var custom_field_four: String?
    var custom_field_five: String?
    var custom_field_six: String?
    var custom_field_seven: String?
    var custom_field_eight: String?
    var custom_field_nine: String?
    var custom_field_ten: String?
    var deceased: Bool?
    var display: String?
    var email: String?
    var email_active: Bool?
    var first_name: String?
    var gendar: String?
    var gender_description: String?
    var greeting: String?
    var host_id: String?
    var last_name: String?
    var lost: Bool?
    var maiden_name: String?
    var middle_name: String?
    var nick_name: String?
    var preferred_name: String?
    var dob: Date?
    var prefix: String?
    var suffix: String?
    var profile_pictures: ProfilePictureUrls?
    var home_languages: [HomeLanguageRead]?
}
