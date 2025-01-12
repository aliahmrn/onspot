import 'package:supabase_flutter/supabase_flutter.dart';

class ComplaintsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchComplaints() async {
    final response = await _client
        .from('complaint')
        .select();

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchAssignedTasksHistory(String category) async {
    final response = await _client
        .from('complaints')
        .select()
        .eq('category', category);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> fetchAssignedTaskDetails(String complaintId) async {
    final response = await _client
        .from('complaints')
        .select()
        .eq('id', complaintId)
        .single();

    return Map<String, dynamic>.from(response);
  }


  Future<void> assignTask(String complaintId, Map<String, dynamic> body) async {
    final response = await _client
        .from('complaints')
        .update(body)
        .eq('id', complaintId);

    if (response.error != null) {
      throw response.error!;
    }
  }


  Future<void> assignTaskAndNotify(
    String complaintId,
    Map<String, dynamic> body,
    List<String> cleanerIds,
    String assignedBy, // Supervisor ID
  ) async {
    // Assign the task (update the complaints table)
    await Supabase.instance.client
        .from('complaints')
        .update(body)
        .eq('id', complaintId);

    // Insert task assignments into the complaint_cleaner table
    final assignments = cleanerIds.map((cleanerId) {
      return {
        'complaint_id': complaintId,
        'cleaner_id': cleanerId,
        'assigned_by': assignedBy,
        'assigned_date': DateTime.now().toIso8601String(),
      };
    }).toList();

    await Supabase.instance.client
        .from('complaint_cleaner')
        .insert(assignments);
  }
  
}