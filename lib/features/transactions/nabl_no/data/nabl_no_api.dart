import 'nabl_no_model.dart';

/// In-memory mock API for NABL No. listing.
class NablNoApi {
  NablNoApi() {
    final now = DateTime.now();
    _items = [
      NablNoRow(
        id: 'nabl-1',
        nablDate: now.subtract(const Duration(days: 2)),
        nablNo: 'NABL-UJ-2026-0112',
        lcDate: now.subtract(const Duration(days: 5)),
        lcNo: 'LCN-2026/05-639',
        typeOfSample: 'LUBE OIL',
        customerName: 'IDEMITSU LUBE INDIA PVT LTD',
        sampleId: 'ES150',
        status: NablNoStatus.pending,
      ),
      NablNoRow(
        id: 'nabl-2',
        nablDate: now.subtract(const Duration(days: 4)),
        nablNo: 'NABL-UJ-2026-0108',
        lcDate: now.subtract(const Duration(days: 7)),
        lcNo: 'LCN-2026/05-640',
        typeOfSample: 'Coolant',
        customerName: 'Coastal Petro',
        sampleId: 'USN585462',
        status: NablNoStatus.authenticated,
      ),
      NablNoRow(
        id: 'nabl-3',
        nablDate: now.subtract(const Duration(days: 6)),
        nablNo: 'NABL-UJ-2026-0104',
        lcDate: now.subtract(const Duration(days: 9)),
        lcNo: 'LCN-2026/05-641',
        typeOfSample: 'Hydraulic fluid',
        customerName: 'Northwind Traders',
        sampleId: 'USN585463',
        status: NablNoStatus.duplicate,
      ),
      NablNoRow(
        id: 'nabl-4',
        nablDate: now.subtract(const Duration(days: 8)),
        nablNo: 'NABL-UJ-2026-0099',
        lcDate: now.subtract(const Duration(days: 12)),
        lcNo: 'LCN-2026/05-642',
        typeOfSample: 'Metal swarf',
        customerName: 'Steelworks Ltd',
        sampleId: 'USN585464',
        status: NablNoStatus.pending,
      ),
      NablNoRow(
        id: 'nabl-5',
        nablDate: now.subtract(const Duration(days: 1)),
        nablNo: 'NABL-UJ-2026-0115',
        lcDate: now.subtract(const Duration(days: 3)),
        lcNo: 'LCN-2026/05-643',
        typeOfSample: 'Process water',
        customerName: 'BioPharm Co',
        sampleId: 'USN585465',
        status: NablNoStatus.authenticated,
      ),
    ];
  }

  late List<NablNoRow> _items;

  Future<List<NablNoRow>> fetchAll() async {
    return List<NablNoRow>.unmodifiable(_items);
  }

  Future<void> deleteMany(Iterable<String> ids) async {
    final remove = ids.toSet();
    _items = _items.where((e) => !remove.contains(e.id)).toList();
  }

  Future<void> authorizeMany(Iterable<String> ids) async {
    final target = ids.toSet();
    if (target.isEmpty) return;
    _items = [
      for (final row in _items)
        if (target.contains(row.id))
          NablNoRow(
            id: row.id,
            nablDate: row.nablDate,
            nablNo: row.nablNo,
            lcDate: row.lcDate,
            lcNo: row.lcNo,
            typeOfSample: row.typeOfSample,
            customerName: row.customerName,
            sampleId: row.sampleId,
            status: NablNoStatus.authenticated,
          )
        else
          row,
    ];
  }
}
