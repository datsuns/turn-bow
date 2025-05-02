import 'package:flutter/material.dart';
import 'services/sheet_service.dart';
import 'services/sheet_data.dart';
import 'services/sheet_type.dart';
import 'services/sheet_templates.dart';

void main() {
  runApp(const MaterialApp(home: SheetListScreen()));
}

class SheetListScreen extends StatefulWidget {
  const SheetListScreen({super.key});

  @override
  State<SheetListScreen> createState() => _SheetListScreenState();
}

class _SheetListScreenState extends State<SheetListScreen> {
  List<String> sheetNames_ = [];
  String? selectedSheet_;
  SheetData? sheetData_;
  TextEditingController yearController_ = TextEditingController();
  TextEditingController memoController_ = TextEditingController();
  ButtonStyle acceptButtonStyle_ = ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent);
  ButtonStyle dangerButtonStyle_ = ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent);
  Color colorRiceField_ = Colors.greenAccent;
  Color colorEquipment_ = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _loadSheets();
  }

  Future<void> _loadSheets() async {
    final sheets = await SheetService.fetchSheetNames();
    setState(() {
      sheetNames_ = sheets;
    });
  }

  Future<void> _loadSheetData(String sheetName) async {
    final data = await SheetService.fetchSheetData(sheetName);
    setState(() {
      selectedSheet_ = sheetName;
      sheetData_ = data;
    });
  }

  void _showYearlyDataDialog() {
    final yearController = TextEditingController();
    final memoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('年別データを追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: '年'),
                keyboardType: TextInputType.number,
              ),
              TextField(controller: memoController, decoration: const InputDecoration(labelText: 'メモ')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('キャンセル')),
            ElevatedButton(
              onPressed: () async {
                final year = yearController.text.trim();
                final memo = memoController.text.trim();
                if (year.isEmpty) return;

                final data = {'年': year, 'メモ': memo};

                try {
                  await SheetService.postYearlyData(selectedSheet_!, data);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  _loadSheetData(selectedSheet_!);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('追加に失敗: $e')));
                }
              },
              style: acceptButtonStyle_,
              child: const Text('追加する'),
            ),
          ],
        );
      },
    );
  }

  void _showFixedValueEditDialog(String key, String currentValue) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('「$key」の値を修正'),
          content: TextField(controller: controller, decoration: const InputDecoration(labelText: '新しい値')),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('キャンセル')),
            ElevatedButton(
              onPressed: () async {
                final newValue = controller.text.trim();
                if (newValue.isEmpty) return;

                try {
                  await SheetService.updateFixedValue(selectedSheet_!, {key: newValue});
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  _loadSheetData(selectedSheet_!);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('修正に失敗: $e')));
                }
              },
              style: acceptButtonStyle_,
              child: const Text('修正する'),
            ),
          ],
        );
      },
    );
  }

  void _showEditYearlyDialog(Map<String, dynamic> rowData) {
    final controllers = <String, TextEditingController>{};
    for (final entry in rowData.entries) {
      controllers[entry.key] = TextEditingController(text: entry.value.toString());
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('年別データの編集'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  controllers.entries.map((entry) {
                    return TextField(controller: entry.value, decoration: InputDecoration(labelText: entry.key));
                  }).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('キャンセル')),
            ElevatedButton(
              onPressed: () async {
                final updatedData = {for (final entry in controllers.entries) entry.key: entry.value.text.trim()};
                try {
                  await SheetService.updateYearlyData(selectedSheet_!, updatedData);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  _loadSheetData(selectedSheet_!);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('更新失敗: $e')));
                }
              },
              style: acceptButtonStyle_,
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteYearDialog() {
    final yearController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('年別データを削除'),
            content: TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: '削除する年'),
              keyboardType: TextInputType.number,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('キャンセル')),
              ElevatedButton(
                onPressed: () async {
                  final year = yearController.text.trim();
                  if (year.isEmpty) return;

                  try {
                    await SheetService.deleteYearlyData(selectedSheet_!, year);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    _loadSheetData(selectedSheet_!);
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('削除失敗: $e')));
                  }
                },
                style: dangerButtonStyle_,
                child: const Text('削除'),
              ),
            ],
          ),
    );
  }

  void _showAddSheetDialog() {
    final nameController = TextEditingController();
    SheetType selectedType = SheetType.ricefield;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('新しいシートを作成'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<SheetType>(
                        value: selectedType,
                        items:
                            SheetType.values
                                .where((e) => e != SheetType.unknown)
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type == SheetType.ricefield ? '田んぼ' : '機材'),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedType = value);
                          }
                        },
                      ),
                      TextField(controller: nameController, decoration: const InputDecoration(labelText: '名前（例：西南）')),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('キャンセル')),
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        final prefix = selectedType == SheetType.ricefield ? '田んぼ_' : '機材_';
                        final sheetName = '$prefix$name';
                        final template = sheetTemplates[selectedType];

                        try {
                          await SheetService.createSheet(
                            sheetName: sheetName,
                            fixedKeys: template?.fixedKeys ?? [],
                            yearlyKeys: template?.yearlyKeys ?? [],
                          );
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          await _loadSheets();
                        } catch (e) {
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('シート作成失敗: \$e')));
                        }
                      },
              style: acceptButtonStyle_,
                      child: const Text('作成する'),
                    ),
                  ],
                ),
          ),
    );
  }

  Color decideDropDownColor(String name) {
    switch (SheetData.sheetNameToType(name)) {
      case SheetType.ricefield:
        return colorRiceField_;
      case SheetType.eqpupment:
        return colorEquipment_;
      default:
        return Colors.transparent;
    }
  }

  Widget _buildDropdown(String? sheetName, List<String> sheetNameList) {
    return DropdownButton<String>(
      hint: const Text('シートを選択'),
      value: sheetName,
      items:
          sheetNameList.map((name) {
            return DropdownMenuItem(value: name, child: Container(color: decideDropDownColor(name), child: Text(name)));
          }).toList(),
      onChanged: (value) {
        if (value != null) _loadSheetData(value);
      },
    );
  }

  Widget _buildTitleBlock(String? sheetName, List<String> sheetNameList) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDropdown(sheetName, sheetNameList),
        ElevatedButton.icon(
          onPressed: _showAddSheetDialog,
          icon: const Icon(Icons.add),
          label: const Text('シート追加'),
          style: acceptButtonStyle_,
        ),
      ],
    );
  }

  Widget _buildFixedValuesTable(SheetData? sheets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('🔒 固定値', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [DataColumn(label: Text('項目')), DataColumn(label: Text('値'))],
            rows:
                sheets!.fixedValues.entries.map<DataRow>((e) {
                  return DataRow(
                    cells: [
                      DataCell(Text(e.key), onLongPress: () => _showFixedValueEditDialog(e.key, e.value)),
                      DataCell(Text(e.value), onLongPress: () => _showFixedValueEditDialog(e.key, e.value)),
                    ],
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildYearlyDataControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('年別データ', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _showYearlyDataDialog,
                icon: const Icon(Icons.add_circle),
                label: const Text('追加'),
                style: acceptButtonStyle_,
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _showDeleteYearDialog,
                icon: const Icon(Icons.delete),
                label: const Text('削除'),
                style: dangerButtonStyle_,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyDataTable(SheetData? sheets) {
    if (sheetData_!.yearlyRows.isEmpty) {
      return const Padding(padding: EdgeInsets.all(8.0), child: Text('年別データがまだありません'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: sheets!.yearlyHeaders.map((h) => DataColumn(label: Text(h))).toList(),
        rows:
            sheets.yearlyRows.map((row) {
              return DataRow(
                onLongPress: () => _showEditYearlyDialog(row),
                cells:
                    sheets.yearlyHeaders.map((h) {
                      return DataCell(Text(row[h] ?? ''));
                    }).toList(),
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('田んぼ・機材リスト')),
      body: Column(
        children: [
          _buildTitleBlock(selectedSheet_, sheetNames_),
          const Divider(),
          if (sheetData_ != null)
            Expanded(
              child: ListView(
                children: [
                  _buildFixedValuesTable(sheetData_),
                  const Divider(),
                  _buildYearlyDataControls(),
                  _buildYearlyDataTable(sheetData_),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
