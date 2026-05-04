/// Per-sample row on a sample intake receipt (data entry grid).
class SampleRowModel {
  const SampleRowModel({
    required this.index,
    required this.sampleId,
    this.equipSrNo = '',
    this.equipIdNo = '',
    this.siteName = '',
    this.subAssemblyNo = '',
    this.make,
    this.model,
    this.typeOfSample,
    this.natureOfSample,
    this.brandOfOil,
    this.grade,
    this.samplingFrom,
    this.typeOfBottle,
    this.problem,
    this.comments,
    this.runningHrs,
    this.subAssemblyHrs,
    this.lubeHrs,
    this.topUpVolume,
    this.sumpCapacity,
    this.qty,
    this.samplingDate,
    this.reportExpected,
    this.customerNote = '',
    this.severity,
    this.oilDrained,
    this.invoiceStatus,
    this.imageAttachment,
    this.ftrAttachment,
    this.invoiceAttachment,
    this.isCompleted = false,
  });

  final int index;
  final String sampleId;

  final String equipSrNo;
  final String equipIdNo;
  final String siteName;
  final String subAssemblyNo;

  final String? make;
  final String? model;
  final String? typeOfSample;
  final String? natureOfSample;
  final String? brandOfOil;
  final String? grade;
  final String? samplingFrom;
  final String? typeOfBottle;
  final String? problem;
  final String? comments;

  final double? runningHrs;
  final double? subAssemblyHrs;
  final double? lubeHrs;
  final double? topUpVolume;
  final double? sumpCapacity;
  final double? qty;

  final DateTime? samplingDate;
  final DateTime? reportExpected;

  final String customerNote;

  final String? severity;
  final String? oilDrained;
  final String? invoiceStatus;

  final String? imageAttachment;
  final String? ftrAttachment;
  final String? invoiceAttachment;

  final bool isCompleted;

  static double? _num(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  SampleRowModel copyWith({
    int? index,
    String? sampleId,
    String? equipSrNo,
    String? equipIdNo,
    String? siteName,
    String? subAssemblyNo,
    Object? make = _sentinel,
    Object? model = _sentinel,
    Object? typeOfSample = _sentinel,
    Object? natureOfSample = _sentinel,
    Object? brandOfOil = _sentinel,
    Object? grade = _sentinel,
    Object? samplingFrom = _sentinel,
    Object? typeOfBottle = _sentinel,
    Object? problem = _sentinel,
    Object? comments = _sentinel,
    Object? runningHrs = _sentinel,
    Object? subAssemblyHrs = _sentinel,
    Object? lubeHrs = _sentinel,
    Object? topUpVolume = _sentinel,
    Object? sumpCapacity = _sentinel,
    Object? qty = _sentinel,
    Object? samplingDate = _sentinel,
    Object? reportExpected = _sentinel,
    String? customerNote,
    Object? severity = _sentinel,
    Object? oilDrained = _sentinel,
    Object? invoiceStatus = _sentinel,
    Object? imageAttachment = _sentinel,
    Object? ftrAttachment = _sentinel,
    Object? invoiceAttachment = _sentinel,
    bool? isCompleted,
  }) {
    return SampleRowModel(
      index: index ?? this.index,
      sampleId: sampleId ?? this.sampleId,
      equipSrNo: equipSrNo ?? this.equipSrNo,
      equipIdNo: equipIdNo ?? this.equipIdNo,
      siteName: siteName ?? this.siteName,
      subAssemblyNo: subAssemblyNo ?? this.subAssemblyNo,
      make: make == _sentinel ? this.make : make as String?,
      model: model == _sentinel ? this.model : model as String?,
      typeOfSample:
          typeOfSample == _sentinel ? this.typeOfSample : typeOfSample as String?,
      natureOfSample: natureOfSample == _sentinel
          ? this.natureOfSample
          : natureOfSample as String?,
      brandOfOil: brandOfOil == _sentinel ? this.brandOfOil : brandOfOil as String?,
      grade: grade == _sentinel ? this.grade : grade as String?,
      samplingFrom:
          samplingFrom == _sentinel ? this.samplingFrom : samplingFrom as String?,
      typeOfBottle:
          typeOfBottle == _sentinel ? this.typeOfBottle : typeOfBottle as String?,
      problem: problem == _sentinel ? this.problem : problem as String?,
      comments: comments == _sentinel ? this.comments : comments as String?,
      runningHrs: runningHrs == _sentinel
          ? this.runningHrs
          : runningHrs as double?,
      subAssemblyHrs: subAssemblyHrs == _sentinel
          ? this.subAssemblyHrs
          : subAssemblyHrs as double?,
      lubeHrs: lubeHrs == _sentinel ? this.lubeHrs : lubeHrs as double?,
      topUpVolume:
          topUpVolume == _sentinel ? this.topUpVolume : topUpVolume as double?,
      sumpCapacity:
          sumpCapacity == _sentinel ? this.sumpCapacity : sumpCapacity as double?,
      qty: qty == _sentinel ? this.qty : qty as double?,
      samplingDate: samplingDate == _sentinel
          ? this.samplingDate
          : samplingDate as DateTime?,
      reportExpected: reportExpected == _sentinel
          ? this.reportExpected
          : reportExpected as DateTime?,
      customerNote: customerNote ?? this.customerNote,
      severity: severity == _sentinel ? this.severity : severity as String?,
      oilDrained: oilDrained == _sentinel ? this.oilDrained : oilDrained as String?,
      invoiceStatus: invoiceStatus == _sentinel
          ? this.invoiceStatus
          : invoiceStatus as String?,
      imageAttachment: imageAttachment == _sentinel
          ? this.imageAttachment
          : imageAttachment as String?,
      ftrAttachment: ftrAttachment == _sentinel
          ? this.ftrAttachment
          : ftrAttachment as String?,
      invoiceAttachment: invoiceAttachment == _sentinel
          ? this.invoiceAttachment
          : invoiceAttachment as String?,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  static const Object _sentinel = Object();

  factory SampleRowModel.empty({required int index, required String sampleId}) {
    return SampleRowModel(
      index: index,
      sampleId: sampleId,
    );
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'sampleId': sampleId,
        'equipSrNo': equipSrNo,
        'equipIdNo': equipIdNo,
        'siteName': siteName,
        'subAssemblyNo': subAssemblyNo,
        'make': make,
        'model': model,
        'typeOfSample': typeOfSample,
        'natureOfSample': natureOfSample,
        'brandOfOil': brandOfOil,
        'grade': grade,
        'samplingFrom': samplingFrom,
        'typeOfBottle': typeOfBottle,
        'problem': problem,
        'comments': comments,
        'runningHrs': runningHrs,
        'subAssemblyHrs': subAssemblyHrs,
        'lubeHrs': lubeHrs,
        'topUpVolume': topUpVolume,
        'sumpCapacity': sumpCapacity,
        'qty': qty,
        'samplingDate': samplingDate?.toIso8601String(),
        'reportExpected': reportExpected?.toIso8601String(),
        'customerNote': customerNote,
        'severity': severity,
        'oilDrained': oilDrained,
        'invoiceStatus': invoiceStatus,
        'imageAttachment': imageAttachment,
        'ftrAttachment': ftrAttachment,
        'invoiceAttachment': invoiceAttachment,
        'isCompleted': isCompleted,
      };

  factory SampleRowModel.fromJson(Map<String, dynamic> m) {
    return SampleRowModel(
      index: (m['index'] as num?)?.toInt() ?? 0,
      sampleId: m['sampleId'] as String? ?? '',
      equipSrNo: m['equipSrNo'] as String? ?? '',
      equipIdNo: m['equipIdNo'] as String? ?? '',
      siteName: m['siteName'] as String? ?? '',
      subAssemblyNo: m['subAssemblyNo'] as String? ?? '',
      make: m['make'] as String?,
      model: m['model'] as String?,
      typeOfSample: m['typeOfSample'] as String?,
      natureOfSample: m['natureOfSample'] as String?,
      brandOfOil: m['brandOfOil'] as String?,
      grade: m['grade'] as String?,
      samplingFrom: m['samplingFrom'] as String?,
      typeOfBottle: m['typeOfBottle'] as String?,
      problem: m['problem'] as String?,
      comments: m['comments'] as String?,
      runningHrs: _num(m['runningHrs']),
      subAssemblyHrs: _num(m['subAssemblyHrs']),
      lubeHrs: _num(m['lubeHrs']),
      topUpVolume: _num(m['topUpVolume']),
      sumpCapacity: _num(m['sumpCapacity']),
      qty: _num(m['qty']),
      samplingDate: m['samplingDate'] != null
          ? DateTime.tryParse(m['samplingDate'] as String)
          : null,
      reportExpected: m['reportExpected'] != null
          ? DateTime.tryParse(m['reportExpected'] as String)
          : null,
      customerNote: m['customerNote'] as String? ?? '',
      severity: m['severity'] as String?,
      oilDrained: m['oilDrained'] as String?,
      invoiceStatus: m['invoiceStatus'] as String?,
      imageAttachment: m['imageAttachment'] as String?,
      ftrAttachment: m['ftrAttachment'] as String?,
      invoiceAttachment: m['invoiceAttachment'] as String?,
      isCompleted: m['isCompleted'] as bool? ?? false,
    );
  }

  SampleRowModel applyPatch(Map<String, dynamic> patch) {
    final merged = Map<String, dynamic>.from(toJson())..addAll(patch);
    return SampleRowModel.fromJson(merged);
  }
}

/// Stable keys for patching / provider updates (storage keys === JSON keys).
enum SampleRowField {
  equipSrNo,
  equipIdNo,
  siteName,
  subAssemblyNo,
  make,
  model,
  typeOfSample,
  natureOfSample,
  brandOfOil,
  grade,
  samplingFrom,
  typeOfBottle,
  problem,
  comments,
  runningHrs,
  subAssemblyHrs,
  lubeHrs,
  topUpVolume,
  sumpCapacity,
  qty,
  samplingDate,
  reportExpected,
  customerNote,
  severity,
  oilDrained,
  invoiceStatus,
  imageAttachment,
  ftrAttachment,
  invoiceAttachment,
}

extension SampleRowFieldKey on SampleRowField {
  String get key => switch (this) {
        SampleRowField.equipSrNo => 'equipSrNo',
        SampleRowField.equipIdNo => 'equipIdNo',
        SampleRowField.siteName => 'siteName',
        SampleRowField.subAssemblyNo => 'subAssemblyNo',
        SampleRowField.make => 'make',
        SampleRowField.model => 'model',
        SampleRowField.typeOfSample => 'typeOfSample',
        SampleRowField.natureOfSample => 'natureOfSample',
        SampleRowField.brandOfOil => 'brandOfOil',
        SampleRowField.grade => 'grade',
        SampleRowField.samplingFrom => 'samplingFrom',
        SampleRowField.typeOfBottle => 'typeOfBottle',
        SampleRowField.problem => 'problem',
        SampleRowField.comments => 'comments',
        SampleRowField.runningHrs => 'runningHrs',
        SampleRowField.subAssemblyHrs => 'subAssemblyHrs',
        SampleRowField.lubeHrs => 'lubeHrs',
        SampleRowField.topUpVolume => 'topUpVolume',
        SampleRowField.sumpCapacity => 'sumpCapacity',
        SampleRowField.qty => 'qty',
        SampleRowField.samplingDate => 'samplingDate',
        SampleRowField.reportExpected => 'reportExpected',
        SampleRowField.customerNote => 'customerNote',
        SampleRowField.severity => 'severity',
        SampleRowField.oilDrained => 'oilDrained',
        SampleRowField.invoiceStatus => 'invoiceStatus',
        SampleRowField.imageAttachment => 'imageAttachment',
        SampleRowField.ftrAttachment => 'ftrAttachment',
        SampleRowField.invoiceAttachment => 'invoiceAttachment',
      };
}
