import 'dart:async';

import 'package:aqui_ajuda_app/model/feedback.dart';
import 'package:aqui_ajuda_app/repository/feedback_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' hide Feedback;

class FeedbackDTO {
  String? id;
  int? efficiency;
  int? accessibility;
  int? security;
  int? organization;
  bool isAvailable;
  String createdBy;
  String? createdByProfilePic;
  String mapPointId;
  Timestamp createdAt;
  String? experience;

  FeedbackDTO({
    this.id,
    this.efficiency,
    this.accessibility,
    this.security,
    this.organization,
    required this.isAvailable,
    required this.createdBy,
    this.createdByProfilePic,
    required this.mapPointId,
    required this.createdAt,
    this.experience,
  });

  factory FeedbackDTO.fromModel(Feedback feedback) {
    return FeedbackDTO(
      id: feedback.id,
      efficiency: feedback.efficiency,
      accessibility: feedback.accessibility,
      security: feedback.security,
      organization: feedback.organization,
      isAvailable: feedback.isAvailable,
      createdBy: feedback.createdBy,
      createdByProfilePic: feedback.createdByProfilePic,
      mapPointId: feedback.mapPointId,
      createdAt: feedback.createdAt,
      experience: feedback.experience,
    );
  }

  Feedback toModel() {
    return Feedback(
      id: id,
      efficiency: efficiency,
      accessibility: accessibility,
      security: security,
      organization: organization,
      isAvailable: isAvailable,
      createdBy: createdBy,
      createdByProfilePic: createdByProfilePic,
      mapPointId: mapPointId,
      createdAt: createdAt,
      experience: experience,
    );
  }
}

class FeedbackViewModel extends ChangeNotifier {
  final FeedbackRepository _repository = FeedbackRepository();
  List<Feedback> _feedbacks = [];
  String _lastFilter = '';
  StreamSubscription? _feedbackSubscription;

  List<FeedbackDTO> get feedbacks =>
      _feedbacks.map((c) => FeedbackDTO.fromModel(c)).toList();

  FeedbackViewModel() {
    _initRepository();
  }

  Future<void> _initRepository() async {
    await loadFeedbacks();
  }

  Future<void> reloadRepository() async {
    await loadFeedbacks(_lastFilter);
  }

  /// 🔄 Carrega e escuta feedbacks em tempo real
  Future<void> loadFeedbacks([String filter = '']) async {
    _lastFilter = filter;

    // Cancela a stream anterior (pra evitar múltiplas inscrições)
    await _feedbackSubscription?.cancel();

    // Escuta o stream do repositório
    _feedbackSubscription = _repository
        .findStream(filter: filter)
        .listen(
          (data) {
            _feedbacks = data;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Erro ao carregar feedbacks: $error');
          },
        );
  }

  @override
  void dispose() {
    _feedbackSubscription?.cancel();
    super.dispose();
  }

  Future<void> addFeedback({required FeedbackDTO dto}) async {
    final feedback = Feedback(
      id: dto.id,
      efficiency: dto.efficiency,
      accessibility: dto.accessibility,
      security: dto.security,
      organization: dto.organization,
      isAvailable: dto.isAvailable,
      createdBy: dto.createdBy,
      createdByProfilePic: dto.createdByProfilePic,
      mapPointId: dto.mapPointId,
      createdAt: dto.createdAt,
      experience: dto.experience,
    );
    await _repository.insert(feedback);
    await loadFeedbacks(_lastFilter);
  }

  Future<void> updateFeedback({
    required id,
    required int efficiency,
    required int acessibility,
    required int security,
    required int organization,
    required bool isAvailable,
    required createdBy,
    required createdByProfilePic,
    required mapPointId,
    required Timestamp createdAt,
    required String experience,
  }) async {
    final feedback = Feedback(
      id: id,
      efficiency: efficiency,
      accessibility: acessibility,
      security: security,
      organization: organization,
      isAvailable: isAvailable,
      createdBy: createdBy,
      createdByProfilePic: createdByProfilePic,
      mapPointId: mapPointId,
      createdAt: createdAt,
      experience: experience,
    );
    await _repository.update(feedback);
    await loadFeedbacks(_lastFilter);
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    await loadFeedbacks(_lastFilter);
  }
}
