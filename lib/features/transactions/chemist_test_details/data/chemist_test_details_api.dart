import 'chemist_test_details_model.dart';

/// Mock chemist test-details workspace data (replace with API later).
class ChemistTestDetailsApi {
  static List<ChemistTestDetailLine> _templateLines(String prefix) => [
        ChemistTestDetailLine(
          id: '${prefix}_l1',
          serialNo: 1,
          testName: 'Wear Metals (ICP)',
          methodType: 'ICP-OES',
          unit: 'ppm',
          value1: '',
          value2: '',
          value3: '',
        ),
        ChemistTestDetailLine(
          id: '${prefix}_l2',
          serialNo: 2,
          testName: 'Viscosity @ 40°C',
          methodType: 'ASTM D445',
          unit: 'cSt',
          value1: '',
          value2: '',
          value3: '',
        ),
        ChemistTestDetailLine(
          id: '${prefix}_l3',
          serialNo: 3,
          testName: 'TBN / TAN',
          methodType: 'Potentiometric',
          unit: 'mg KOH/g',
          value1: '',
          value2: '',
          value3: '',
        ),
        ChemistTestDetailLine(
          id: '${prefix}_l4',
          serialNo: 4,
          testName: 'Water Content',
          methodType: 'Karl Fischer',
          unit: 'ppm',
          value1: '',
          value2: '',
          value3: '',
        ),
      ];

  Future<List<ChemistTestSummaryRow>> fetchSummaries() async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    final now = DateTime.now();
    return [
      ChemistTestSummaryRow(
        id: 'ctd_1',
        labDate: now.subtract(const Duration(days: 2)),
        labNo: 'LAB-2026-01482',
        testCount: 4,
        expectedDate: now.add(const Duration(days: 3)),
        sample: 'Used Oil — Engine #HD785',
      ),
      ChemistTestSummaryRow(
        id: 'ctd_2',
        labDate: now.subtract(const Duration(days: 1)),
        labNo: 'LAB-2026-01491',
        testCount: 4,
        expectedDate: now.add(const Duration(days: 2)),
        sample: 'Hydraulic — Swing Motor',
      ),
      ChemistTestSummaryRow(
        id: 'ctd_3',
        labDate: now.subtract(const Duration(hours: 20)),
        labNo: 'LAB-2026-01503',
        testCount: 4,
        expectedDate: now.add(const Duration(days: 5)),
        sample: 'Coolant — Radiator Flush',
      ),
      ChemistTestSummaryRow(
        id: 'ctd_4',
        labDate: now.subtract(const Duration(hours: 8)),
        labNo: 'LAB-2026-01507',
        testCount: 4,
        expectedDate: null,
        sample: 'Grease — Final Drive EP2',
      ),
      ChemistTestSummaryRow(
        id: 'ctd_5',
        labDate: now.subtract(const Duration(hours: 3)),
        labNo: 'LAB-2026-01512',
        testCount: 4,
        expectedDate: now.add(const Duration(days: 1)),
        sample: 'Used Oil — Transmission PC200',
      ),
    ];
  }

  Future<List<ChemistTestDetailLine>> fetchDetailLines(String summaryId) async {
    await Future<void>.delayed(const Duration(milliseconds: 25));
    return _templateLines(summaryId)
        .map(
          (e) => ChemistTestDetailLine(
            id: e.id,
            serialNo: e.serialNo,
            testName: e.testName,
            methodType: e.methodType,
            unit: e.unit,
            value1: e.value1,
            value2: e.value2,
            value3: e.value3,
          ),
        )
        .toList(growable: false);
  }
}
