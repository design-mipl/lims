// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'package:flutter/material.dart';

import 'dart:html' as html;

import 'lab_sample_label_data.dart';
import 'lab_sample_label_html.dart';

Future<bool> printLabSampleLabels(
  BuildContext context,
  List<LabSampleLabelData> labels,
) async {
  if (labels.isEmpty) return false;

  final doc = buildLabSampleLabelsHtml(labels);
  final stamp = DateTime.now();
  final filename =
      'lab-labels-${stamp.year}${stamp.month.toString().padLeft(2, '0')}${stamp.day.toString().padLeft(2, '0')}.html';

  final blob = html.Blob(<Object>[doc], 'text/html;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();

  html.window.open(url, '_blank');
  return true;
}
