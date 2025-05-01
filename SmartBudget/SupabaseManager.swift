//
//  SupabaseManager.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/28.
//

import Foundation
import Supabase

class SupabaseManager {
    // Singleton instance
    static let shared = SupabaseManager()
    
    // Supabase client
    let supabase: SupabaseClient
    
    private init() {
        // Initialize Supabase client with your project URL and anon key
        // Replace these with your actual Supabase project credentials
        supabase = SupabaseClient(
          supabaseURL: URL(string: "https://oosntvyhhqbotzfkhmzv.supabase.co")!,
          supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9vc250dnloaHFib3R6ZmtobXp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU4NzI2NjcsImV4cCI6MjA2MTQ0ODY2N30._dTT4pXqLYT5oC_KBG0HsgdUStOcLNJ-x4rAEsQKngU"
        )
    }
    
    // MARK: - Authentication Methods
    
    // Sign up with email and password
    func signUp(email: String, password: String, username: String? = nil) async throws -> AuthResponse {
        let response = try await supabase.auth.signUp(
            email: email,
            password: password,
            data: username != nil ? ["name": AnyJSON.string(username!)] : nil
        )
        return response
    }
    
    // Sign in with email and password
    func signIn(email: String, password: String) async throws -> Session {
        let response = try await supabase.auth.signIn(
            email: email,
            password: password
        )
        return response
    }
    
    // Sign out
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
    
    // Check if user is signed in
    func isSignedIn() async -> Bool {
        let session = try? await supabase.auth.session
        return session != nil
    }
    
    // Get current user
    func getCurrentUser() async -> User? {
        if let session = try? await supabase.auth.session {
            return session.user
        }
        return nil
    }
    
    func getCurrentUserName() async -> String {
        if let user = await getCurrentUser() {
            // Try to get the name from user metadata
            if let metadata = user.userMetadata as? [String: Any],
               let name = metadata["name"] as? String {
                return name
            }
            
            // If name is not in metadata, use the email or a default
            if let email = user.email {
                // Extract name from email (before @)
                if let atIndex = email.firstIndex(of: "@") {
                    return String(email[..<atIndex])
                }
                return email
            }
        }
        return "Anonymous User"
    }
}
