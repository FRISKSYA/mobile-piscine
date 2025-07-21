import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithGitHub();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  
  AuthRemoteDataSourceImpl({required this.supabaseClient});
  
  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final response = await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.diaryapp://login-callback/',
      );
      
      if (!response) {
        throw const AppAuthException('Failed to sign in with Google');
      }
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AppAuthException('No user found after sign in');
      }
      
      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException(e.toString());
    }
  }
  
  @override
  Future<UserModel> signInWithGitHub() async {
    try {
      final response = await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: 'io.supabase.diaryapp://login-callback/',
      );
      
      if (!response) {
        throw const AppAuthException('Failed to sign in with GitHub');
      }
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AppAuthException('No user found after sign in');
      }
      
      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException(e.toString());
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }
  
  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }
  
  @override
  Stream<UserModel?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    });
  }
}