import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class AppTable extends StatelessWidget {
  final List<DataColumn> columns;
  final DataTableSource source;
  final double minWidth;
  final bool? sortAscending;
  final int? sortColumnIndex;
  const AppTable(
      {required this.columns,
      required this.source,
      this.minWidth = 600,
      this.sortAscending,
      this.sortColumnIndex,
      super.key});

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      empty: const Center(
        child: Text(
          'No Data found',
          style: TextStyle(fontSize: 18),
        ),
      ),
      minWidth: minWidth,
      wrapInCard: false,
      fixedColumnsColor: Colors.black,
      border: TableBorder.all(color: Colors.black),
      rowsPerPage: 10,
      renderEmptyRowsInTheEnd: false,
      headingRowHeight: 50,
      horizontalMargin: 20,
      columnSpacing: 20,
      sortAscending: sortAscending ?? true,
      sortColumnIndex: sortColumnIndex ?? 0,
      // dataRowHeight: 50,

      headingRowColor:
          MaterialStateProperty.all(Theme.of(context).primaryColor),
      headingTextStyle: const TextStyle(fontSize: 18, color: Colors.white),
      isHorizontalScrollBarVisible: true,
      fixedCornerColor: Colors.green,
      dataTextStyle: const TextStyle(fontSize: 20, color: Colors.black),
      columns: columns,
      source: source,
    );
  }
}
