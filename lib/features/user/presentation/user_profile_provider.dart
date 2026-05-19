import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/user_profile_repository.dart';
import '../domain/entities/user_profile.dart';

part 'user_profile_provider.g.dart';

final _repo = UserProfileRepository();

@riverpod
Future<UserProfile?> userProfile(Ref ref) async {
  return _repo.load();
}

@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  Future<UserProfile?> build() async {
    return _repo.load();
  }

  Future<void> save(UserProfile profile) async {
    await _repo.save(profile);
    state = AsyncData(profile);
  }

  Future<void> clear() async {
    await _repo.clear();
    state = const AsyncData(null);
  }
}
