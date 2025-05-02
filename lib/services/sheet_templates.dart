import 'sheet_type.dart';

class SheetTemplate {
  final List<String> fixedKeys;
  final List<String> yearlyKeys;

  const SheetTemplate({
    required this.fixedKeys,
    required this.yearlyKeys,
  });
}

const Map<SheetType, SheetTemplate> sheetTemplates = {
  SheetType.ricefield: SheetTemplate(
    fixedKeys: ['名前', '広さ', 'メモ'],
    yearlyKeys: ['年', '収穫量', '苗の量', '肥料の量', '殺虫剤の量', 'メモ'],
  ),
  SheetType.eqpupment: SheetTemplate(
    fixedKeys: ['名前', '金額', 'メモ'],
    yearlyKeys: ['年', '使い方メモ'],
  ),
};
