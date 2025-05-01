import UIKit
import Supabase

struct Group: Codable {
    var groupName: String
    var groupMembers: [String]
    var memberNames: [String]
    var id: String
    
    enum CodingKeys: String, CodingKey {
        case groupName = "group_name"
        case groupMembers = "group_members"
        case memberNames = "member_names"
        case id
    }
    
    init(name: String, members: [String], member_names: [String], id: String = UUID().uuidString) {
        self.groupName = name
        self.groupMembers = members
        self.memberNames = member_names
        self.id = id
    }
}

extension Group {
    static func fetchGroups() async throws -> [Group] {
        let query = SupabaseManager.shared.supabase.database
            .from("Group")
            .select()
        
        let groups: [Group] = try await query.execute().value
        return groups
    }
    
    static func fetchGroupsForUser(userId: String) async throws -> [Group] {
        let query = SupabaseManager.shared.supabase.database
            .from("Group")
            .select()
            .contains("group_members", value: [userId])
        
        let groups: [Group] = try await query.execute().value
        return groups
    }
    
    func save() async throws {
        guard let user = await SupabaseManager.shared.getCurrentUser() else {
            throw NSError(domain: "Not authenticated", code: 401)
        }
        
        // Debug: Print the current auth.uid from Supabase
        let authUserIDResponse = try? await SupabaseManager.shared.supabase.database
            .rpc("get_auth_uid")
            .execute()
        
        print("Auth UID from Supabase: \(String(describing: authUserIDResponse?.data))")
        print("Group members in request: \(self.groupMembers)")
        
        // Create a struct specifically for sending to Supabase
        struct GroupUpload: Encodable {
            let id: String
            let group_name: String
            let group_members: [String]
            let member_names: [String]
        }
        
        // Create an uploadable version with the correct field names
        let groupData = GroupUpload(
            id: self.id,
            group_name: self.groupName,
            group_members: self.groupMembers,
            member_names: self.memberNames
        )
        print(groupData)
        
//        print("Saving group with ID: \(id), name: \(groupName)")
        
        do {
            // Use upsert instead of conditional update/insert
            let response = try await SupabaseManager.shared.supabase
                .from("Group")
                .upsert(groupData)
                .execute()
            
            print("Group saved successfully")
            return
        } catch {
            print("Error saving group: \(error)")
            throw error
        }
    }
}
