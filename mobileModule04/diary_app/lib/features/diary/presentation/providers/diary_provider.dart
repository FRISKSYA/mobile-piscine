import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/diary_remote_datasource.dart';
import '../../data/repositories/diary_repository_impl.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../../domain/usecases/create_diary_entry.dart';
import '../../domain/usecases/delete_diary_entry.dart';
import '../../domain/usecases/get_diary_entries.dart';
import '../../domain/usecases/get_diary_entry.dart';

// Data Source Provider
final diaryRemoteDataSourceProvider = Provider<DiaryRemoteDataSource>((ref) {
  return DiaryRemoteDataSourceImpl(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

// Repository Provider
final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  return DiaryRepositoryImpl(
    remoteDataSource: ref.watch(diaryRemoteDataSourceProvider),
  );
});

// Use Cases Providers
final getDiaryEntriesUseCaseProvider = Provider<GetDiaryEntries>((ref) {
  return GetDiaryEntries(ref.watch(diaryRepositoryProvider));
});

final getDiaryEntryUseCaseProvider = Provider<GetDiaryEntry>((ref) {
  return GetDiaryEntry(ref.watch(diaryRepositoryProvider));
});

final createDiaryEntryUseCaseProvider = Provider<CreateDiaryEntry>((ref) {
  return CreateDiaryEntry(ref.watch(diaryRepositoryProvider));
});

final deleteDiaryEntryUseCaseProvider = Provider<DeleteDiaryEntry>((ref) {
  return DeleteDiaryEntry(ref.watch(diaryRepositoryProvider));
});

// Diary Entries List Provider
final diaryEntriesProvider = FutureProvider<List<DiaryEntry>>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];
  
  final getDiaryEntries = ref.watch(getDiaryEntriesUseCaseProvider);
  final result = await getDiaryEntries(user.id);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (entries) => entries,
  );
});

// Single Diary Entry Provider
final diaryEntryProvider = FutureProvider.family<DiaryEntry, String>((ref, id) async {
  final getDiaryEntry = ref.watch(getDiaryEntryUseCaseProvider);
  final result = await getDiaryEntry(id);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (entry) => entry,
  );
});

// Diary State Notifier for CRUD operations
class DiaryNotifier extends StateNotifier<AsyncValue<void>> {
  final CreateDiaryEntry _createDiaryEntry;
  final DeleteDiaryEntry _deleteDiaryEntry;
  final Ref _ref;
  
  DiaryNotifier({
    required CreateDiaryEntry createDiaryEntry,
    required DeleteDiaryEntry deleteDiaryEntry,
    required Ref ref,
  }) : _createDiaryEntry = createDiaryEntry,
       _deleteDiaryEntry = deleteDiaryEntry,
       _ref = ref,
       super(const AsyncValue.data(null));
  
  Future<void> createEntry({
    required DateTime date,
    required String title,
    required String mood,
    required String content,
  }) async {
    state = const AsyncValue.loading();
    
    final user = _ref.read(authStateProvider).valueOrNull;
    if (user == null) {
      state = AsyncValue.error('User not logged in', StackTrace.current);
      return;
    }
    
    final params = CreateDiaryEntryParams(
      userId: user.id,
      userEmail: user.email,
      date: date,
      title: title,
      mood: mood,
      content: content,
    );
    
    final result = await _createDiaryEntry(params);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) {
        state = const AsyncValue.data(null);
        // Refresh the diary entries list
        _ref.invalidate(diaryEntriesProvider);
      },
    );
  }
  
  Future<void> deleteEntry(String id) async {
    state = const AsyncValue.loading();
    
    final result = await _deleteDiaryEntry(id);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) {
        state = const AsyncValue.data(null);
        // Refresh the diary entries list
        _ref.invalidate(diaryEntriesProvider);
      },
    );
  }
}

// Diary Notifier Provider
final diaryNotifierProvider = StateNotifierProvider<DiaryNotifier, AsyncValue<void>>((ref) {
  return DiaryNotifier(
    createDiaryEntry: ref.watch(createDiaryEntryUseCaseProvider),
    deleteDiaryEntry: ref.watch(deleteDiaryEntryUseCaseProvider),
    ref: ref,
  );
});