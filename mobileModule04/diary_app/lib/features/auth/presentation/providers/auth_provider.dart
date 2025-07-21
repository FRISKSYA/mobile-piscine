import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_github.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';

// Supabase Client Provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Data Source Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

// Use Cases Providers
final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogle>((ref) {
  return SignInWithGoogle(ref.watch(authRepositoryProvider));
});

final signInWithGitHubUseCaseProvider = Provider<SignInWithGitHub>((ref) {
  return SignInWithGitHub(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
});

// Auth State Provider
final authStateProvider = StreamProvider<DiaryUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// Auth State Notifier for handling auth actions
class AuthNotifier extends StateNotifier<AsyncValue<DiaryUser?>> {
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithGitHub _signInWithGitHub;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;
  
  AuthNotifier({
    required SignInWithGoogle signInWithGoogle,
    required SignInWithGitHub signInWithGitHub,
    required SignOut signOut,
    required GetCurrentUser getCurrentUser,
  }) : _signInWithGoogle = signInWithGoogle,
       _signInWithGitHub = signInWithGitHub,
       _signOut = signOut,
       _getCurrentUser = getCurrentUser,
       super(const AsyncValue.loading()) {
    _init();
  }
  
  Future<void> _init() async {
    final result = await _getCurrentUser();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }
  
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await _signInWithGoogle();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }
  
  Future<void> signInWithGitHub() async {
    state = const AsyncValue.loading();
    final result = await _signInWithGitHub();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }
  
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final result = await _signOut();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }
}

// Auth Notifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<DiaryUser?>>((ref) {
  return AuthNotifier(
    signInWithGoogle: ref.watch(signInWithGoogleUseCaseProvider),
    signInWithGitHub: ref.watch(signInWithGitHubUseCaseProvider),
    signOut: ref.watch(signOutUseCaseProvider),
    getCurrentUser: ref.watch(getCurrentUserUseCaseProvider),
  );
});