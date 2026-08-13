import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/activity_forecast/presentation/widgets/activity_result_actions.dart';

void main() {
  testWidgets('lays out four result commands as equal 2 by 2 buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: ActivityResultActions(
                onEditConditions: () {},
                onRecalculate: () {},
                onSaveAsNew: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      ),
    );

    Rect commandRect(String label) => tester.getRect(
      find.ancestor(of: find.text(label), matching: find.byType(InkWell)),
    );
    final edit = commandRect('조건 변경');
    final recalculate = commandRect('다시 계산');
    final save = commandRect('저장');
    final delete = commandRect('삭제');

    expect(edit.height, ActivityResultActions.buttonHeight);
    expect(recalculate.height, edit.height);
    expect(save.height, edit.height);
    expect(delete.height, edit.height);
    expect(recalculate.top, edit.top);
    expect(delete.top, save.top);
    expect(save.top, greaterThan(edit.top));
    expect(recalculate.width, closeTo(edit.width, 0.01));
    expect(delete.width, closeTo(save.width, 0.01));
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('조건 변경'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps labels visible with enlarged system text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
          child: Scaffold(
            body: SizedBox(
              width: 280,
              child: ActivityResultActions(
                onEditConditions: () {},
                onRecalculate: () {},
                onSaveAsNew: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('저장'), findsOneWidget);
    expect(find.text('삭제'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
}
