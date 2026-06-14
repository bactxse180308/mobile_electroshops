import 'dart:async';
import 'package:flutter/material.dart';

class PagingResult<T> {
  final List<T> content;
  final int totalElements;
  final bool isLast;

  PagingResult({
    required this.content,
    required this.totalElements,
    required this.isLast,
  });
}

mixin PagingControllerMixin<T> {
  List<T> items = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  int currentPage = 0;
  int totalCount = 0;
  String? errorMessage;

  Timer? _debounceTimer;

  void debounce(VoidCallback action, {Duration duration = const Duration(milliseconds: 500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, action);
  }

  void resetPaging() {
    currentPage = 0;
    items = [];
    hasMore = true;
    errorMessage = null;
  }

  Future<void> loadPage({
    required Future<PagingResult<T>> Function(int page) fetcher,
    required VoidCallback onUpdate,
    bool reset = false,
  }) async {
    if (reset) {
      if (isLoading) return;
      isLoading = true;
      errorMessage = null;
      currentPage = 0;
      items = [];
      hasMore = true;
      onUpdate();
    } else {
      if (isLoadingMore || !hasMore) return;
      isLoadingMore = true;
      onUpdate();
    }

    try {
      final pageToLoad = reset ? 0 : currentPage + 1;
      final result = await fetcher(pageToLoad);

      if (reset) {
        items = result.content;
        currentPage = 0;
      } else {
        items.addAll(result.content);
        currentPage++;
      }
      totalCount = result.totalElements;
      hasMore = !result.isLast;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      isLoadingMore = false;
      onUpdate();
    }
  }

  void disposePaging() {
    _debounceTimer?.cancel();
  }
}
