// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_edit_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaskEditViewModel)
const taskEditViewModelProvider = TaskEditViewModelFamily._();

final class TaskEditViewModelProvider
    extends $AsyncNotifierProvider<TaskEditViewModel, Task> {
  const TaskEditViewModelProvider._({
    required TaskEditViewModelFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'taskEditViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskEditViewModelHash();

  @override
  String toString() {
    return r'taskEditViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskEditViewModel create() => TaskEditViewModel();

  @override
  bool operator ==(Object other) {
    return other is TaskEditViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskEditViewModelHash() => r'59d25ba1deab87b202a9cd246c9b0510b8def0d9';

final class TaskEditViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskEditViewModel,
          AsyncValue<Task>,
          Task,
          FutureOr<Task>,
          int?
        > {
  const TaskEditViewModelFamily._()
    : super(
        retry: null,
        name: r'taskEditViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TaskEditViewModelProvider call(int? taskId) =>
      TaskEditViewModelProvider._(argument: taskId, from: this);

  @override
  String toString() => r'taskEditViewModelProvider';
}

abstract class _$TaskEditViewModel extends $AsyncNotifier<Task> {
  late final _$args = ref.$arg as int?;
  int? get taskId => _$args;

  FutureOr<Task> build(int? taskId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<Task>, Task>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Task>, Task>,
              AsyncValue<Task>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
