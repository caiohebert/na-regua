import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:na_regua/db/admin_db.dart';
import 'package:na_regua/providers/barber_profile_provider.dart';
import 'package:na_regua/utils/date.dart';

class BarberTimeSlotsTab extends ConsumerStatefulWidget {
  const BarberTimeSlotsTab({super.key});

  @override
  ConsumerState<BarberTimeSlotsTab> createState() => _BarberTimeSlotsTabState();
}

class _BarberTimeSlotsTabState extends ConsumerState<BarberTimeSlotsTab> {
  final int _startHour = 7;
  final int _endHour = 20; // last slot start
  final double _cellHeight = 48;
  final double _timeColWidth = 72;

  // selected keys for template: 'W|HH:MM:SS' where W = weekday (1=Mon..7=Sun)
  final Set<String> _selected = {};
  final Set<String> _existing = {}; // existing occurrences in next 90 days stored as 'W|HH:MM:SS'

  // which weekdays are enabled for recurring template (1..7). Default Mon-Fri
  final Set<int> _weekdaysEnabled = {1, 2, 3, 4, 5};

  // drag state
  bool _isDragging = false;
  int? _dragStartRow;
  int? _dragStartCol;

  // template weekdays Monday..Friday
  List<int> get _templateWeekdays => [1, 2, 3, 4, 5];

  List<TimeOfDay> get _times {
    final times = <TimeOfDay>[];
    for (var h = _startHour; h <= _endHour; h++) {
      times.add(TimeOfDay(hour: h, minute: 0));
      if (!(h == _endHour && 30 > 0)) times.add(TimeOfDay(hour: h, minute: 30));
    }
    // trim to end at _endHour:30 if necessary
    return times.where((t) => t.hour < _endHour || (t.hour == _endHour && t.minute == 0)).toList();
  }

  String _cellKeyFor(int row, int col) {
    final weekday = _templateWeekdays[col];
    final time = _times[row];
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
    return '$weekday|$timeStr';
  }

  /// Fetch existing slots for the next [daysAhead] days (default 90)
  /// and mark which template weekday/time keys already have at least one occurrence.
  Future<void> _fetchExisting(String barberId, {int daysAhead = 90}) async {
    try {
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: daysAhead));
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('time_slots')
          .select('date,time')
          .gte('date', getDate(startDate))
          .lte('date', getDate(endDate))
          .eq('barber_id', barberId);
      final rows = res as List<dynamic>;
      final seen = <String>{};
      for (var r in rows) {
        final m = r as Map<String, dynamic>;
        final dateStr = m['date'] as String;
        final timeStr = m['time'] as String;
        final dt = DateTime.parse('$dateStr $timeStr');
        final wk = dt.weekday; // 1..7
        seen.add('$wk|$timeStr');
      }
      setState(() {
        _existing
          ..clear()
          ..addAll(seen);
        _selected.removeWhere((s) => _existing.contains(s));
      });
    } catch (_) {}
  }

  // no-op helper removed; clearing done inline where needed

  /// Generate concrete date+time slots for next N days (default 90) for the
  /// currently selected template weekday/time combos, filter out already
  /// existing date/time slots and bulk insert the remainder.
  Future<void> _saveSelection(String barberId, {int daysAhead = 90}) async {
    if (_selected.isEmpty) return;

    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: daysAhead));

    // Generate all target date/time pairs
    final targets = <Map<String, String>>[];
    for (var d = startDate; !d.isAfter(endDate); d = d.add(const Duration(days: 1))) {
      if (!_weekdaysEnabled.contains(d.weekday)) continue;
      for (var sel in _selected) {
        final parts = sel.split('|');
        final wk = int.parse(parts[0]);
        final time = parts[1];
        if (wk != d.weekday) continue;
        targets.add({'date': getDate(d), 'time': time});
      }
    }

    if (targets.isEmpty) return;

    // Fetch existing concrete slots in the date range to avoid duplicates
    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('time_slots')
          .select('date,time')
          .gte('date', getDate(startDate))
          .lte('date', getDate(endDate))
          .eq('barber_id', barberId);
      final rows = res as List<dynamic>;
      final existingConcrete = <String>{};
      for (var r in rows) {
        final m = r as Map<String, dynamic>;
        existingConcrete.add('${m['date']}|${m['time']}');
      }

      final toInsert = targets.where((t) => !existingConcrete.contains('${t['date']}|${t['time']}')).toList();
      if (toInsert.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhum horário novo para criar')));
        return;
      }

      final created = await insertTimeSlotsBulk(toInsert.map((m) => {'date': m['date']!, 'time': m['time']!}).toList());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Criados $created horários')));
      // refresh existing markers
      await _fetchExisting(barberId, daysAhead: daysAhead);
      setState(() => _selected.clear());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  void _onPanStart(Offset localPos, double gridLeft, double cellW) {
    final dx = localPos.dx - gridLeft;
    final dy = localPos.dy;
    if (dx < 0) return;
    final col = (dx / cellW).floor();
    final row = (dy / _cellHeight).floor();
    if (col < 0 || col >= _templateWeekdays.length || row < 0 || row >= _times.length) return;
    _isDragging = true;
    _dragStartRow = row;
    _dragStartCol = col;
    _updateSelection(row, col);
  }

  void _onPanUpdate(Offset localPos, double gridLeft, double cellW) {
    if (!_isDragging || _dragStartRow == null || _dragStartCol == null) return;
    final dx = localPos.dx - gridLeft;
    final dy = localPos.dy;
    if (dx < 0) return;
    final col = (dx / cellW).floor();
    final row = (dy / _cellHeight).floor();
    if (col < 0 || col >= _templateWeekdays.length || row < 0 || row >= _times.length) return;
    _updateSelection(row, col);
  }

  void _onPanEnd() {
    _isDragging = false;
    _dragStartRow = null;
    _dragStartCol = null;
  }

  void _updateSelection(int row, int col) {
    final sr = _dragStartRow!;
    final sc = _dragStartCol!;
    final r0 = min(sr, row);
    final r1 = max(sr, row);
    final c0 = min(sc, col);
    final c1 = max(sc, col);
    final newSel = <String>{};
    for (var r = r0; r <= r1; r++) {
      for (var c = c0; c <= c1; c++) {
        final key = _cellKeyFor(r, c);
        if (!_existing.contains(key)) newSel.add(key);
      }
    }
    setState(() {
      _selected
        ..clear()
        ..addAll(newSel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final barberAsync = ref.watch(barberProfileProvider);
    return barberAsync.when(
      data: (profile) {
        if (profile == null) return const Center(child: Text('Crie seu perfil de barbeiro para gerenciar horários'));
        final barberId = profile['id'] as String;

        // ensure we loaded existing markers for next 90 days
        _fetchExisting(barberId);

        return Column(
          children: [
            // Weekday toggles (Mon-Fri default enabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Row(
                children: _templateWeekdays.map((wk) {
                  final enabled = _weekdaysEnabled.contains(wk);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(_weekdayName(wk)),
                      selected: enabled,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _weekdaysEnabled.add(wk);
                          } else {
                            _weekdaysEnabled.remove(wk);
                            // also drop selections for that weekday
                            _selected.removeWhere((s) => s.startsWith('$wk|'));
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _saveSelection(barberId),
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar próximos 3 meses'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => setState(() => _selected.clear()),
                    child: const Text('Limpar'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _fetchExisting(barberId),
                    child: const Text('Recarregar'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Grid
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final gridLeft = _timeColWidth;
                final cellW = (constraints.maxWidth - _timeColWidth) / _templateWeekdays.length;
                return Column(
                  children: [
                    // Header row with weekdays
                    SizedBox(
                      height: 40,
                      child: Row(children: [
                        SizedBox(width: _timeColWidth, child: const Center(child: Text('Horário'))),
                        ..._templateWeekdays.map((d) => Expanded(child: Center(child: Text(_weekdayName(d))))),
                      ]),
                    ),
                    const Divider(height: 1),
                    // Grid area
                    Expanded(
                      child: GestureDetector(
                        onPanStart: (details) => _onPanStart(details.localPosition, gridLeft, cellW),
                        onPanUpdate: (details) => _onPanUpdate(details.localPosition, gridLeft, cellW),
                        onPanEnd: (_) => _onPanEnd(),
                        child: SingleChildScrollView(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // time column
                              Column(
                                children: _times
                                    .map((t) => SizedBox(
                                          height: _cellHeight,
                                          width: _timeColWidth,
                                          child: Center(child: Text('${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')),
                                        ))
                                    .toList(),
                              ),
                              // days grid
                              SizedBox(
                                width: cellW * _templateWeekdays.length,
                                child: Column(
                                  children: _times.map((time) {
                                    final row = _times.indexOf(time);
                                    return Row(
                                      children: List.generate(_templateWeekdays.length, (colIdx) {
                                        final key = _cellKeyFor(row, colIdx);
                                        final weekday = _templateWeekdays[colIdx];
                                        final occupied = _existing.contains(key);
                                        final selected = _selected.contains(key);
                                        final enabled = _weekdaysEnabled.contains(weekday);
                                        return GestureDetector(
                                          onTap: () {
                                            if (!enabled) return;
                                            setState(() {
                                              if (occupied) {
                                                // no-op for occupied cells (could implement removal later)
                                              } else {
                                                if (selected) {
                                                  _selected.remove(key);
                                                } else {
                                                  _selected.add(key);
                                                }
                                              }
                                            });
                                          },
                                          child: SizedBox(
                                            width: cellW,
                                            height: _cellHeight,
                                            child: Container(
                                              margin: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: occupied
                                                    ? Colors.grey[400]
                                                    : (selected ? Colors.blue.shade400 : Colors.white),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: enabled ? Colors.grey.shade300 : Colors.grey.shade200, width: 0.8),
                                                boxShadow: selected
                                                  ? [BoxShadow(color: Colors.blue.withValues(alpha: 0.18), blurRadius: 6, offset: const Offset(0, 2))]
                                                  : null,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Erro: $e')),
    );
  }

  static String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Seg';
      case DateTime.tuesday:
        return 'Ter';
      case DateTime.wednesday:
        return 'Qua';
      case DateTime.thursday:
        return 'Qui';
      case DateTime.friday:
        return 'Sex';
      case DateTime.saturday:
        return 'Sáb';
      case DateTime.sunday:
        return 'Dom';
      default:
        return '';
    }
  }
}

