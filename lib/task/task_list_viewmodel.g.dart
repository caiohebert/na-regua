// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaskListViewModel)
const taskListViewModelProvider = TaskListViewModelProvider._();

final class TaskListViewModelProvider
    extends $AsyncNotifierProvider<TaskListViewModel, List<Task>> {
  const TaskListViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskListViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskListViewModelHash();

  @$internal
  @override
  TaskListViewModel create() => TaskListViewModel();
}

String _$taskListViewModelHash() => r'c4dc01587351e0b429c1ef3923ed54c76a392882';

abstract class _$TaskListViewModel extends $AsyncNotifier<List<Task>> {
  FutureOr<List<Task>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Task>>, List<Task>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Task>>, List<Task>>,
              AsyncValue<List<Task>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
