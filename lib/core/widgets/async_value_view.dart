import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `AsyncValue<T>`의 loading/error/data 상태를 일관된 UI로 렌더링하는 헬퍼 위젯.
///
/// 화면마다 `.when(...)`을 반복해서 작성하지 않도록 공통 로딩/에러 뷰를 제공한다.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final WidgetBuilder? loading;
  final Widget Function(Object error, StackTrace stackTrace)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () =>
          loading?.call(context) ??
          const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          error?.call(err, stack) ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '문제가 발생했어요: $err',
                textAlign: TextAlign.center,
              ),
            ),
          ),
    );
  }
}
