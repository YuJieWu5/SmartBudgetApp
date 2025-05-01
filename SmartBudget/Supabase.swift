//
//  Supabase.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/28.
//

import Foundation
import Supabase

let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://oosntvyhhqbotzfkhmzv.supabase.co")!,
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9vc250dnloaHFib3R6ZmtobXp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU4NzI2NjcsImV4cCI6MjA2MTQ0ODY2N30._dTT4pXqLYT5oC_KBG0HsgdUStOcLNJ-x4rAEsQKngU"
)
