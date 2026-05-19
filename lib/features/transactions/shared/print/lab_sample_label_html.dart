import 'lab_sample_label_data.dart';

/// Builds print-ready HTML for A4 lab sample labels (portal layout).
String buildLabSampleLabelsHtml(
  List<LabSampleLabelData> labels, {
  String documentTitle = 'Lab Sample Labels',
}) {
  final labelBlocks = labels.map((label) {
    return '''
<div class="label">
  <div class="date">${_escape(label.formattedDate)}</div>
  <div class="type">${_escape(label.sampleTypeDisplay)}</div>
  <div class="lcn">${_escape(label.labCodeNumber)}</div>
</div>''';
  }).join('\n');

  return '''
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>$documentTitle</title>
<style>
$_labelStyles
</style>
</head>
<body>
<div class="sheet">
$labelBlocks
</div>
<script>
window.onload = function() {
  setTimeout(function() { window.print(); }, 300);
};
</script>
</body>
</html>''';
}

String _escape(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

const String _labelStyles = '''
@page { size: A4 portrait; margin: 12mm; }
* { box-sizing: border-box; }
body {
  margin: 0;
  padding: 0;
  background: #fff;
  font-family: Arial, Helvetica, sans-serif;
  color: #000;
  -webkit-print-color-adjust: exact;
  print-color-adjust: exact;
}
.sheet {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 0;
}
.label {
  width: 78mm;
  min-height: 32mm;
  padding: 5mm 6mm;
  margin-bottom: 6mm;
  background: #fff;
  border: 0.4mm solid #000;
  page-break-inside: avoid;
  break-inside: avoid;
}
.label .date {
  font-size: 11pt;
  font-weight: 700;
  line-height: 1.2;
  margin: 0 0 3mm 0;
}
.label .type {
  font-size: 11pt;
  font-weight: 700;
  line-height: 1.25;
  margin: 0 0 3mm 0;
  text-transform: uppercase;
}
.label .lcn {
  font-size: 13pt;
  font-weight: 800;
  line-height: 1.2;
  margin: 0;
  letter-spacing: 0.03em;
}
@media print {
  body { background: #fff; }
  .label { margin-bottom: 5mm; }
}
''';
