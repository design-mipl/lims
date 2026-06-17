import 'package:flutter/material.dart';

import 'lab_sample_label_data.dart';
import 'lab_sample_label_print_stub.dart'
    if (dart.library.html) 'lab_sample_label_print_web.dart' as impl;

/// Opens a print-ready label document and triggers browser print / download.
Future<bool> printLabSampleLabels(
  BuildContext context,
  List<LabSampleLabelData> labels,
) =>
    impl.printLabSampleLabels(context, labels);
