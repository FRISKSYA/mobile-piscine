import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/diary_entry_model.dart';

abstract class DiaryRemoteDataSource {
  Future<List<DiaryEntryModel>> getDiaryEntries(String userId);
  Future<DiaryEntryModel> getDiaryEntry(String id);
  Future<DiaryEntryModel> createDiaryEntry({
    required String userId,
    required String userEmail,
    required DateTime date,
    required String title,
    required String mood,
    required String content,
  });
  Future<DiaryEntryModel> updateDiaryEntry(DiaryEntryModel entry);
  Future<void> deleteDiaryEntry(String id);
}

class DiaryRemoteDataSourceImpl implements DiaryRemoteDataSource {
  final SupabaseClient supabaseClient;
  
  DiaryRemoteDataSourceImpl({required this.supabaseClient});
  
  @override
  Future<List<DiaryEntryModel>> getDiaryEntries(String userId) async {
    try {
      final response = await supabaseClient
          .from(SupabaseConstants.diaryEntriesTable)
          .select()
          .eq(SupabaseConstants.columnUserId, userId)
          .order(SupabaseConstants.columnDate, ascending: false);
      
      return (response as List)
          .map((json) => DiaryEntryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw AppServerException(e.toString());
    }
  }
  
  @override
  Future<DiaryEntryModel> getDiaryEntry(String id) async {
    try {
      final response = await supabaseClient
          .from(SupabaseConstants.diaryEntriesTable)
          .select()
          .eq(SupabaseConstants.columnId, id)
          .single();
      
      return DiaryEntryModel.fromJson(response);
    } catch (e) {
      throw AppServerException(e.toString());
    }
  }
  
  @override
  Future<DiaryEntryModel> createDiaryEntry({
    required String userId,
    required String userEmail,
    required DateTime date,
    required String title,
    required String mood,
    required String content,
  }) async {
    try {
      final data = {
        SupabaseConstants.columnUserId: userId,
        SupabaseConstants.columnUserEmail: userEmail,
        SupabaseConstants.columnDate: date.toIso8601String(),
        SupabaseConstants.columnTitle: title,
        SupabaseConstants.columnMood: mood,
        SupabaseConstants.columnContent: content,
      };
      
      final response = await supabaseClient
          .from(SupabaseConstants.diaryEntriesTable)
          .insert(data)
          .select()
          .single();
      
      return DiaryEntryModel.fromJson(response);
    } catch (e) {
      throw AppServerException(e.toString());
    }
  }
  
  @override
  Future<DiaryEntryModel> updateDiaryEntry(DiaryEntryModel entry) async {
    try {
      final data = {
        SupabaseConstants.columnTitle: entry.title,
        SupabaseConstants.columnMood: entry.mood,
        SupabaseConstants.columnContent: entry.content,
        SupabaseConstants.columnDate: entry.date.toIso8601String(),
      };
      
      final response = await supabaseClient
          .from(SupabaseConstants.diaryEntriesTable)
          .update(data)
          .eq(SupabaseConstants.columnId, entry.id)
          .select()
          .single();
      
      return DiaryEntryModel.fromJson(response);
    } catch (e) {
      throw AppServerException(e.toString());
    }
  }
  
  @override
  Future<void> deleteDiaryEntry(String id) async {
    try {
      await supabaseClient
          .from(SupabaseConstants.diaryEntriesTable)
          .delete()
          .eq(SupabaseConstants.columnId, id);
    } catch (e) {
      throw AppServerException(e.toString());
    }
  }
}