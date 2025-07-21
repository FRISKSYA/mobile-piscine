import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? name,
    String? avatarUrl,
  }) = _UserModel;
  
  const UserModel._();
  
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  factory UserModel.fromSupabaseUser(supabase.User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] ?? user.userMetadata?['full_name'],
      avatarUrl: user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
    );
  }
  
  DiaryUser toEntity() => DiaryUser(
    id: id,
    email: email,
    name: name,
    avatarUrl: avatarUrl,
  );
}