import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:moz_updated_version/data/firebase/data/model/user_stats_model.dart';
import 'package:moz_updated_version/data/model/user_model/repository/user_repo.dart';
import 'package:moz_updated_version/services/service_locator.dart';

part 'user_stats_state.dart';

class UserStatsCubit extends Cubit<UserStatsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserStatsCubit() : super(UserStatsInitial());

  Future<void> loadUserStats() async {
    try {
      final userId = sl<UserStorageAbRepo>().userID;

      if (userId == null) {
        emit(
          const UserStatsLoaded(
            UserStats(totalSongsPlayed: 0, totalListeningTime: Duration.zero),
          ),
        );
        return;
      }

      emit(UserStatsLoading());

      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        emit(
          const UserStatsLoaded(
            UserStats(totalSongsPlayed: 0, totalListeningTime: Duration.zero),
          ),
        );
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      final stats = UserStats.fromMap(data['stats']);

      emit(UserStatsLoaded(stats));
    } catch (e, stack) {
      log('Error loading user stats: $e', stackTrace: stack);
      emit(UserStatsError(e.toString()));
    }
  }
}
