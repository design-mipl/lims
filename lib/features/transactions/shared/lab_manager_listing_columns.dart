import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../design_system/components/components.dart';
import '../../../design_system/tokens.dart';
import 'lab_manager_listing_row.dart';
import 'lab_verification_progress.dart';

/// Single width for all Lab Manager listing data columns (even rhythm).
const double _kLmColUniform = 160;

/// Count of data columns from [buildLabManagerListingColumns] (scrollable area).
const int _kLmListingColumnCount = 23;

/// Verification vs certification listing column/filter presets.
enum LabManagerListingColumnsMode {
  /// Header select filters on brand and grade (Lab Manager Verification).
  verification,

  /// Same columns; brand/grade column filters omitted (Certification).
  certification,
}

List<AppSelectItem<String>> _selectItems(Iterable<String> values) => [
      for (final v in values) AppSelectItem<String>(value: v, label: v),
    ];

Widget _textCell(String text, {Color? color}) {
  return Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.start,
    style: GoogleFonts.poppins(
      fontSize: AppTokens.tableCellSize,
      color: color ?? AppTokens.textPrimary,
    ),
  );
}

/// Columns for Lab Manager Verification / Certification listings.
///
/// The Verified column shows only `x/total` progress text from test lines.
List<TableColumn<LabManagerListingRow>> buildLabManagerListingColumns({
  required LabManagerListingColumnsMode mode,
}) {
  final includeBrandAndGradeFilters =
      mode == LabManagerListingColumnsMode.verification;
  final sampleTypeItems = _selectItems(LabManagerListingFilterOptions.sampleTypes);
  final brandItems = _selectItems(LabManagerListingFilterOptions.brands);
  final gradeItems = _selectItems(LabManagerListingFilterOptions.grades);

  Widget verifiedCell(LabManagerListingRow r) {
    return Text(
      labWorkflowVerifiedProgressText(r.testLines),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
      style: GoogleFonts.poppins(
        fontSize: AppTokens.tableCellSize,
        fontWeight: AppTokens.weightMedium,
        color: AppTokens.textPrimary,
      ),
    );
  }

  return [
    TableColumn<LabManagerListingRow>(
      key: 'verified',
      label: 'Verified',
      width: _kLmColUniform,
      sortable: false,
      cellBuilder: verifiedCell,
    ),
    TableColumn<LabManagerListingRow>(
      key: 'companyName',
      label: 'Company Name',
      width: _kLmColUniform,
      sortable: false,
      filter: const AppColumnFilter(type: AppColumnFilterType.text),
      filterTextValue: (r) => r.companyName,
      cellBuilder: (r) => _textCell(r.companyName),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'siteName',
      label: 'Site Name',
      width: _kLmColUniform,
      sortable: false,
      filter: const AppColumnFilter(type: AppColumnFilterType.text),
      filterTextValue: (r) => r.siteName,
      cellBuilder: (r) => _textCell(r.siteName),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'typeOfSample',
      label: 'Type Of Sample',
      width: _kLmColUniform,
      sortable: false,
      filter: AppColumnFilter(
        type: AppColumnFilterType.select,
        options: sampleTypeItems,
      ),
      filterSelectValue: (r) => r.typeOfSample,
      cellBuilder: (r) => _textCell(r.typeOfSample),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'samplingDate',
      label: 'Sampling Date',
      width: _kLmColUniform,
      sortable: true,
      sortValue: (r) => r.samplingDate.millisecondsSinceEpoch,
      cellBuilder: (r) =>
          _textCell(LabManagerListingRow.formatYmd(r.samplingDate)),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'lotNo',
      label: 'Lot No.',
      width: _kLmColUniform,
      sortable: false,
      filter: const AppColumnFilter(type: AppColumnFilterType.text),
      filterTextValue: (r) => r.lotNo,
      cellBuilder: (r) => _textCell(r.lotNo),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'labId',
      label: 'Lab Id',
      width: _kLmColUniform,
      sortable: false,
      filter: const AppColumnFilter(type: AppColumnFilterType.text),
      filterTextValue: (r) => r.labId,
      cellBuilder: (r) => _textCell(r.labId),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'labDate',
      label: 'Lab Date',
      width: _kLmColUniform,
      sortable: false,
      filter: const AppColumnFilter(type: AppColumnFilterType.text),
      filterTextValue: (r) => LabManagerListingRow.formatYmd(r.labDate),
      cellBuilder: (r) =>
          _textCell(LabManagerListingRow.formatYmd(r.labDate)),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'lubeHrs',
      label: 'Lube Hrs',
      width: _kLmColUniform,
      sortable: true,
      sortValue: (r) => r.lubeHrs,
      cellBuilder: (r) => _textCell(r.lubeHrs.toStringAsFixed(0)),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'hmr',
      label: 'HMR',
      width: _kLmColUniform,
      sortable: false,
      cellBuilder: (r) => _textCell(r.hmr),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'dateOfReceipt',
      label: 'Date Of Receipt',
      width: _kLmColUniform,
      sortable: true,
      sortValue: (r) => r.dateOfReceipt.millisecondsSinceEpoch,
      cellBuilder: (r) =>
          _textCell(LabManagerListingRow.formatYmd(r.dateOfReceipt)),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'equipmentNo',
      label: 'Equipment No.',
      width: _kLmColUniform,
      sortable: false,
      cellBuilder: (r) => _textCell(r.equipmentNo),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'sampleId',
      label: 'Sample Id',
      width: _kLmColUniform,
      sortable: false,
      cellBuilder: (r) => _textCell(r.sampleId),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'make',
      label: 'Make',
      width: _kLmColUniform,
      sortable: false,
      cellBuilder: (r) => _textCell(r.make),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'model',
      label: 'Model',
      width: _kLmColUniform,
      sortable: false,
      filter: const AppColumnFilter(type: AppColumnFilterType.text),
      filterTextValue: (r) => r.model,
      cellBuilder: (r) => _textCell(r.model),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'serialNo',
      label: 'Serial No.',
      width: _kLmColUniform,
      sortable: false,
      filter: const AppColumnFilter(type: AppColumnFilterType.text),
      filterTextValue: (r) => r.serialNo,
      cellBuilder: (r) => _textCell(r.serialNo),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'brandOfOil',
      label: 'Brand of Oil',
      width: _kLmColUniform,
      sortable: false,
      filter: includeBrandAndGradeFilters
          ? AppColumnFilter(
              type: AppColumnFilterType.select,
              options: brandItems,
            )
          : null,
      filterSelectValue:
          includeBrandAndGradeFilters ? (r) => r.brandOfOil : null,
      cellBuilder: (r) => _textCell(r.brandOfOil),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'grade',
      label: 'Grade',
      width: _kLmColUniform,
      sortable: false,
      filter: includeBrandAndGradeFilters
          ? AppColumnFilter(
              type: AppColumnFilterType.select,
              options: gradeItems,
            )
          : null,
      filterSelectValue: includeBrandAndGradeFilters ? (r) => r.grade : null,
      cellBuilder: (r) => _textCell(r.grade),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'referenceNo',
      label: 'Reference No.',
      width: _kLmColUniform,
      sortable: false,
      cellBuilder: (r) => _textCell(r.referenceNo),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'narration',
      label: 'Narration',
      width: _kLmColUniform,
      sortable: false,
      cellBuilder: (r) => _textCell(r.narration),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'additionalRemarks',
      label: 'Additional Remarks',
      width: _kLmColUniform,
      sortable: false,
      cellBuilder: (r) => _textCell(r.additionalRemarks),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'customerNotes',
      label: 'Customer Notes',
      width: _kLmColUniform,
      sortable: false,
      cellBuilder: (r) => _textCell(r.customerNotes),
    ),
    TableColumn<LabManagerListingRow>(
      key: 'reportId',
      label: 'Report Id',
      width: _kLmColUniform,
      sortable: false,
      cellBuilder: (r) => _textCell(r.reportId),
    ),
  ];
}

/// Sum of data column widths (excludes listing checkbox + actions chrome).
double get labManagerListingDataColumnsWidth =>
    _kLmColUniform * _kLmListingColumnCount;
