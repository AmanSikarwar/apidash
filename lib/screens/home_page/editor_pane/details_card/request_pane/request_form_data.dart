import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:apidash/providers/providers.dart';
import 'package:apidash/widgets/widgets.dart';
import 'package:apidash/models/models.dart';
import 'package:apidash/utils/utils.dart';
import 'package:apidash/consts.dart';

class FormDataWidget extends ConsumerStatefulWidget {
  const FormDataWidget({super.key});
  @override
  ConsumerState<FormDataWidget> createState() => _FormDataBodyState();
}

class _FormDataBodyState extends ConsumerState<FormDataWidget> {
  late int seed;
  final random = Random.secure();
  late List<FormDataModel> rows;
  @override
  void initState() {
    super.initState();
    seed = random.nextInt(kRandMax);
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedIdStateProvider);
    var formRows = ref.read(selectedRequestModelProvider)?.requestFormDataList;
    rows =
        formRows == null || formRows.isEmpty ? [kFormDataEmptyModel] : formRows;

    List<DataColumn> columns = const [
      DataColumn2(
        label: Text('Key'),
      ),
      DataColumn2(
        label: Text('='),
        fixedWidth: 30,
      ),
      DataColumn2(
        label: Text('Value'),
      ),
      DataColumn2(
        label: Text('Remove'),
        fixedWidth: 32,
      ),
    ];

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: kBorderRadius12,
          ),
          margin: kP10,
          child: Column(
            children: [
              Expanded(
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(scrollbarTheme: kDataTableScrollbarTheme),
                  child: DataTable2(
                    columnSpacing: 12,
                    dividerThickness: 0,
                    horizontalMargin: 0,
                    headingRowHeight: 0,
                    dataRowHeight: kDataRowHeight,
                    bottomMargin: kDataTableBottomPadding,
                    isVerticalScrollBarVisible: true,
                    columns: columns,
                    rows: List<DataRow>.generate(
                      rows.length,
                      (index) {
                        return DataRow(
                          key: ValueKey("$selectedId-$index-form-row-$seed"),
                          cells: <DataCell>[
                            DataCell(
                              Theme(
                                data: Theme.of(context),
                                child: FormDataField(
                                  keyId: "$selectedId-$index-form-v-$seed",
                                  initialValue: rows[index].name,
                                  hintText: "Add Key",
                                  onChanged: (value) {
                                    rows[index] = rows[index].copyWith(
                                      name: value,
                                    );
                                    _onFieldChange(selectedId!);
                                  },
                                  colorScheme: Theme.of(context).colorScheme,
                                  formDataType: rows[index].type,
                                  onFormDataTypeChanged: (value) {
                                    rows[index] = rows[index].copyWith(
                                      type: value ?? FormDataType.text,
                                    );
                                    rows[index] =
                                        rows[index].copyWith(value: "");
                                    setState(() {});
                                    _onFieldChange(selectedId!);
                                  },
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                "=",
                                style: kCodeStyle,
                              ),
                            ),
                            DataCell(
                              rows[index].type == FormDataType.file
                                  ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Theme(
                                              data: Theme.of(context),
                                              child: ElevatedButton.icon(
                                                icon: const Icon(
                                                  Icons.snippet_folder_rounded,
                                                  size: 20,
                                                ),
                                                style: ButtonStyle(
                                                  shape:
                                                      MaterialStatePropertyAll(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  var pickedResult =
                                                      await pickFile();
                                                  if (pickedResult != null &&
                                                      pickedResult
                                                          .files.isNotEmpty &&
                                                      pickedResult.files.first
                                                              .path !=
                                                          null) {
                                                    rows[index] =
                                                        rows[index].copyWith(
                                                      value: pickedResult
                                                          .files.first.path!,
                                                    );
                                                    setState(() {});
                                                    _onFieldChange(selectedId!);
                                                  }
                                                },
                                                label: Text(
                                                  (rows[index].type ==
                                                              FormDataType
                                                                  .file &&
                                                          rows[index]
                                                              .value
                                                              .isNotEmpty)
                                                      ? rows[index]
                                                          .value
                                                          .toString()
                                                      : "Select File",
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      kFormDataButtonLabelTextStyle,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : CellField(
                                      keyId: "$selectedId-$index-form-v-$seed",
                                      initialValue: rows[index].value,
                                      hintText: "Add Value",
                                      onChanged: (value) {
                                        rows[index] =
                                            rows[index].copyWith(value: value);
                                        _onFieldChange(selectedId!);
                                      },
                                      colorScheme:
                                          Theme.of(context).colorScheme,
                                    ),
                            ),
                            DataCell(
                              InkWell(
                                child: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? kIconRemoveDark
                                    : kIconRemoveLight,
                                onTap: () {
                                  seed = random.nextInt(kRandMax);
                                  if (rows.length == 1) {
                                    setState(() {
                                      rows = [kFormDataEmptyModel];
                                    });
                                  } else {
                                    rows.removeAt(index);
                                  }
                                  _onFieldChange(selectedId!);
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  rows.add(kFormDataEmptyModel);
                });
                _onFieldChange(selectedId!);
              },
              icon: const Icon(Icons.add),
              label: const Text(
                "Add Form Data",
                style: kTextStyleButton,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onFieldChange(String selectedId) {
    ref.read(collectionStateNotifierProvider.notifier).update(
          selectedId,
          requestFormDataList: rows,
        );
  }
}
