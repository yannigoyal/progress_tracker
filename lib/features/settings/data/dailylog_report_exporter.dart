import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/models/category.dart';
import '../../../core/models/log_entry.dart';
import '../../../core/models/project.dart';

class DailyLogReportExporter {
  const DailyLogReportExporter();

  static const fileName = 'dailylog_report.docx';
  static const _mimeType =
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  static const _androidDownloadsChannel = MethodChannel('daily_log/downloads');

  Future<ExportedReport> export({
    required List<LogEntry> logs,
    required List<Project> projects,
  }) async {
    final bytes = _DailyLogDocxReport(
      logs: logs,
      projects: projects,
      exportedAt: DateTime.now(),
    ).build();

    if (Platform.isAndroid) return _exportAndroid(bytes);

    final directory = await _downloadsDirectory();
    await directory.create(recursive: true);
    final file = File('${directory.path}${Platform.pathSeparator}$fileName');

    await file.writeAsBytes(bytes, flush: true);
    return ExportedReport(displayPath: file.path, filePath: file.path);
  }

  Future<void> open(ExportedReport report) async {
    if (Platform.isAndroid && report.contentUri != null) {
      await _androidDownloadsChannel.invokeMethod<void>('openUri', {
        'uri': report.contentUri,
        'mimeType': _mimeType,
      });
      return;
    }

    final path = report.filePath;
    final command = path == null ? null : _openCommand(path);
    if (command == null) {
      throw UnsupportedError('Opening reports is not supported here.');
    }

    final result = await Process.run(command.executable, command.arguments);
    if (result.exitCode != 0) {
      throw ProcessException(
        command.executable,
        command.arguments,
        result.stderr,
        result.exitCode,
      );
    }
  }

  Future<ExportedReport> _exportAndroid(Uint8List bytes) async {
    final result = await _androidDownloadsChannel
        .invokeMapMethod<String, dynamic>('saveToDownloads', {
          'bytes': bytes,
          'fileName': fileName,
          'mimeType': _mimeType,
        });

    final contentUri = result?['uri'] as String?;
    if (contentUri == null || contentUri.isEmpty) {
      throw const FormatException(
        'Android download save did not return a URI.',
      );
    }

    return ExportedReport(
      contentUri: contentUri,
      displayPath: result?['displayPath'] as String? ?? 'Downloads/$fileName',
    );
  }

  Future<Directory> _downloadsDirectory() async {
    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads;
    } catch (_) {}

    if (Platform.isAndroid) return Directory('/storage/emulated/0/Download');

    final home = _homeDirectoryPath();
    if (home != null && home.isNotEmpty) {
      return Directory('$home${Platform.pathSeparator}Downloads');
    }

    return Directory('Downloads');
  }

  String? _homeDirectoryPath() {
    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null && userProfile.isNotEmpty) return userProfile;

      final homeDrive = Platform.environment['HOMEDRIVE'];
      final homePath = Platform.environment['HOMEPATH'];
      if (homeDrive != null &&
          homeDrive.isNotEmpty &&
          homePath != null &&
          homePath.isNotEmpty) {
        return '$homeDrive$homePath';
      }
    }

    return Platform.environment['HOME'];
  }

  _OpenCommand? _openCommand(String path) {
    if (Platform.isWindows) {
      return _OpenCommand('rundll32', ['url.dll,FileProtocolHandler', path]);
    }
    if (Platform.isMacOS) return _OpenCommand('open', [path]);
    if (Platform.isLinux) return _OpenCommand('xdg-open', [path]);
    return null;
  }
}

class ExportedReport {
  const ExportedReport({
    required this.displayPath,
    this.filePath,
    this.contentUri,
  });

  final String displayPath;
  final String? filePath;
  final String? contentUri;
}

class _OpenCommand {
  const _OpenCommand(this.executable, this.arguments);

  final String executable;
  final List<String> arguments;
}

class _DailyLogDocxReport {
  _DailyLogDocxReport({
    required this.logs,
    required this.projects,
    required this.exportedAt,
  });

  static const _brandColor = '5D48D0';
  static const _summaryRowColor = 'F5F3FF';
  static const _white = 'FFFFFF';
  static const _bodySize = 20;
  static const _heading1Size = 40;
  static const _heading2Size = 28;
  static const _bullet = '\u2022';

  final List<LogEntry> logs;
  final List<Project> projects;
  final DateTime exportedAt;

  Uint8List build() {
    final archive = _DocxArchive();
    archive.add('[Content_Types].xml', _contentTypesXml());
    archive.add('_rels/.rels', _rootRelationshipsXml());
    archive.add('docProps/app.xml', _appPropertiesXml());
    archive.add('docProps/core.xml', _corePropertiesXml());
    archive.add('word/_rels/document.xml.rels', _documentRelationshipsXml());
    archive.add('word/document.xml', _documentXml());
    archive.add('word/footer1.xml', _footerXml());
    archive.add('word/styles.xml', _stylesXml());
    return archive.finish();
  }

  String _documentXml() {
    final buffer = StringBuffer()
      ..write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
      ..write(
        '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">',
      )
      ..write('<w:body>');

    _appendCoverPage(buffer);
    buffer.write(_pageBreak());
    _appendSummary(buffer);
    buffer.write(_pageBreak());
    _appendHeatmap(buffer);
    buffer.write(_pageBreak());
    _appendDailyHistory(buffer);
    buffer.write(_pageBreak());
    _appendProjects(buffer);

    buffer
      ..write(_sectionProperties())
      ..write('</w:body></w:document>');
    return buffer.toString();
  }

  void _appendCoverPage(StringBuffer buffer) {
    buffer
      ..write(
        _paragraph(
          'DailyLog Progress Report',
          styleId: 'Heading1',
          alignment: 'center',
          after: 320,
        ),
      )
      ..write(_divider())
      ..write(
        _paragraph(
          'Exported ${DateFormat('MMMM d, yyyy, h:mm a').format(exportedAt)}',
          alignment: 'center',
          after: 180,
        ),
      )
      ..write(
        _paragraph(
          'Total days tracked: ${_trackedDays.length}',
          alignment: 'center',
          after: 80,
        ),
      )
      ..write(
        _paragraph(
          'Total entries: ${logs.length}',
          alignment: 'center',
          after: 80,
        ),
      );
  }

  void _appendSummary(StringBuffer buffer) {
    buffer
      ..write(_paragraph('Summary', styleId: 'Heading1', after: 80))
      ..write(_divider())
      ..write(_summaryTable());
  }

  void _appendHeatmap(StringBuffer buffer) {
    buffer
      ..write(_paragraph('Activity Heatmap', styleId: 'Heading1', after: 80))
      ..write(_divider());

    final days = _trackedDays.toList()..sort();
    if (days.isNotEmpty) {
      buffer.write(
        _paragraph(
          'Range: ${DateFormat('MMM d, yyyy').format(days.first)} - '
          '${DateFormat('MMM d, yyyy').format(days.last)}',
          after: 120,
        ),
      );
    }

    for (final line in _heatmapLines()) {
      buffer.write(_paragraph(line, fontFamily: 'Courier New', after: 40));
    }
  }

  void _appendDailyHistory(StringBuffer buffer) {
    buffer
      ..write(_paragraph('Daily History', styleId: 'Heading1', after: 80))
      ..write(_divider());

    final byDay = _logsByDay();
    if (byDay.isEmpty) {
      buffer.write(_paragraph('No entries recorded.'));
      return;
    }

    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final day in days) {
      buffer.write(
        _paragraph(
          DateFormat('MMMM d, yyyy').format(day),
          styleId: 'Heading2',
          before: 120,
          after: 80,
        ),
      );

      final dayLogs = byDay[day]!..sort(_sortLogsDesc);
      for (final category in Category.values) {
        final categoryLogs = dayLogs
            .where((log) => log.category == category)
            .toList();
        if (categoryLogs.isEmpty) continue;

        buffer.write(
          _paragraph(
            '${_categoryEmoji(category)} ${category.name}',
            bold: true,
            color: _brandColor,
            after: 40,
          ),
        );

        for (final log in categoryLogs) {
          buffer.write(
            _paragraph(
              '$_bullet ${_titleAndSubtitle(log)}',
              leftIndent: 360,
              after: 40,
            ),
          );
        }
      }
    }
  }

  void _appendProjects(StringBuffer buffer) {
    buffer
      ..write(_paragraph('Projects', styleId: 'Heading1', after: 80))
      ..write(_divider());

    final reports = _projectReports();
    if (reports.isEmpty) {
      buffer.write(_paragraph('No projects recorded.'));
      return;
    }

    for (final report in reports) {
      buffer
        ..write(
          _paragraph(report.name, styleId: 'Heading2', before: 120, after: 60),
        )
        ..write(_paragraph('Status: ${report.status}', bold: true, after: 80));

      if (report.entries.isEmpty) {
        buffer.write(
          _paragraph(
            '$_bullet No entries recorded.',
            leftIndent: 360,
            after: 40,
          ),
        );
        continue;
      }

      for (final entry in report.entries..sort(_sortLogsDesc)) {
        buffer.write(
          _paragraph(
            '$_bullet ${_projectEntryText(entry)}',
            leftIndent: 360,
            after: 40,
          ),
        );
      }
    }
  }

  String _summaryTable() {
    final rows = StringBuffer()
      ..write(
        _tableRow([
          _TableCell('category', fill: _brandColor, color: _white, bold: true),
          _TableCell('count', fill: _brandColor, color: _white, bold: true),
          _TableCell(
            '% of total',
            fill: _brandColor,
            color: _white,
            bold: true,
          ),
        ]),
      );
    final total = logs.length;
    final counts = _categoryCounts();

    for (var i = 0; i < Category.values.length; i++) {
      final category = Category.values[i];
      final count = counts[category] ?? 0;
      final percent = total == 0 ? 0 : (count / total) * 100;
      final fill = i.isOdd ? _summaryRowColor : null;

      rows.write(
        _tableRow([
          _TableCell(category.name, fill: fill),
          _TableCell('$count', fill: fill),
          _TableCell('${percent.toStringAsFixed(1)}%', fill: fill),
        ]),
      );
    }

    return '''
<w:tbl>
  <w:tblPr>
    <w:tblW w:w="0" w:type="auto"/>
    <w:tblBorders>
      <w:top w:val="single" w:sz="4" w:space="0" w:color="D9D3FF"/>
      <w:left w:val="single" w:sz="4" w:space="0" w:color="D9D3FF"/>
      <w:bottom w:val="single" w:sz="4" w:space="0" w:color="D9D3FF"/>
      <w:right w:val="single" w:sz="4" w:space="0" w:color="D9D3FF"/>
      <w:insideH w:val="single" w:sz="4" w:space="0" w:color="D9D3FF"/>
      <w:insideV w:val="single" w:sz="4" w:space="0" w:color="D9D3FF"/>
    </w:tblBorders>
    <w:tblCellMar>
      <w:top w:w="120" w:type="dxa"/>
      <w:left w:w="120" w:type="dxa"/>
      <w:bottom w:w="120" w:type="dxa"/>
      <w:right w:w="120" w:type="dxa"/>
    </w:tblCellMar>
  </w:tblPr>
  <w:tblGrid>
    <w:gridCol w:w="3400"/>
    <w:gridCol w:w="1800"/>
    <w:gridCol w:w="2200"/>
  </w:tblGrid>
  $rows
</w:tbl>
''';
  }

  String _tableRow(List<_TableCell> cells) {
    return '<w:tr>${cells.map(_tableCell).join()}</w:tr>';
  }

  String _tableCell(_TableCell cell) {
    final fill = cell.fill == null
        ? ''
        : '<w:shd w:val="clear" w:color="auto" w:fill="${cell.fill}"/>';
    return '''
<w:tc>
  <w:tcPr>
    <w:tcW w:w="2400" w:type="dxa"/>
    $fill
  </w:tcPr>
  ${_paragraph(cell.text, bold: cell.bold, color: cell.color, after: 0)}
</w:tc>
''';
  }

  List<String> _heatmapLines() {
    final byDay = _entryCountsByDay();
    if (byDay.isEmpty) {
      return const [
        'Legend: \u00B7 = 0, \u2591 = 1, \u2592 = 2, \u2593 = 3+',
        'Mon  \u00B7',
        'Tue  \u00B7',
        'Wed  \u00B7',
        'Thu  \u00B7',
        'Fri  \u00B7',
        'Sat  \u00B7',
        'Sun  \u00B7',
      ];
    }

    final days = byDay.keys.toList()..sort();
    final start = _weekStart(days.first);
    final end = _weekStart(days.last);
    final weekCount = end.difference(start).inDays ~/ 7 + 1;
    final labels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final lines = <String>[
      'Legend: \u00B7 = 0, \u2591 = 1, \u2592 = 2, \u2593 = 3+',
    ];

    for (var dayOffset = 0; dayOffset < DateTime.daysPerWeek; dayOffset++) {
      final cells = <String>[];
      for (var week = 0; week < weekCount; week++) {
        final date = start.add(Duration(days: week * 7 + dayOffset));
        cells.add(_heatmapShade(byDay[date] ?? 0));
      }
      lines.add('${labels[dayOffset]}  ${cells.join(' ')}');
    }

    return lines;
  }

  String _heatmapShade(int count) => switch (count) {
    0 => '\u00B7',
    1 => '\u2591',
    2 => '\u2592',
    _ => '\u2593',
  };

  String _titleAndSubtitle(LogEntry log) {
    final title = log.displayTitle.trim().isEmpty
        ? 'Untitled'
        : log.displayTitle.trim();
    final subtitle = log.displaySubtitle.trim();
    return subtitle.isEmpty ? title : '$title - $subtitle';
  }

  String _projectEntryText(LogEntry log) {
    final date = DateFormat('MMM d, yyyy').format(log.createdAt.toLocal());
    final whatDone = (log.payload['whatDone'] as String?)?.trim();
    final text = whatDone?.isNotEmpty == true ? whatDone! : 'No details';
    return '$date - $text';
  }

  String _categoryEmoji(Category category) => switch (category) {
    Category.dsa => '\u{1F4D8}',
    Category.content => '\u{1F3AC}',
    Category.workout => '\u{1F4AA}',
    Category.reading => '\u{1F4D6}',
    Category.learning => '\u{1F9E0}',
    Category.misc => '\u{1F5D2}',
    Category.project => '\u{1F680}',
  };

  List<_ProjectReport> _projectReports() {
    final reports = <_ProjectReport>[];
    final usedLogIds = <int>{};
    final projectLogs =
        logs.where((log) => log.category == Category.project).toList()
          ..sort(_sortLogsDesc);

    for (final project in projects) {
      final entries = projectLogs
          .where((log) => _isProjectEntry(log, project))
          .toList();
      usedLogIds.addAll(entries.map((entry) => entry.id));
      reports.add(
        _ProjectReport(
          name: project.name.trim().isEmpty ? 'Untitled Project' : project.name,
          status: project.status.name,
          entries: entries,
        ),
      );
    }

    final orphaned = <String, List<LogEntry>>{};
    for (final log in projectLogs) {
      if (usedLogIds.contains(log.id)) continue;
      final name = (log.payload['projectName'] as String?)?.trim();
      final key = (name?.isNotEmpty == true ? name! : 'Untitled Project')
          .toLowerCase();
      (orphaned[key] ??= []).add(log);
    }

    for (final entry in orphaned.entries) {
      final firstName = (entry.value.first.payload['projectName'] as String?)
          ?.trim();
      reports.add(
        _ProjectReport(
          name: firstName?.isNotEmpty == true ? firstName! : 'Untitled Project',
          status: 'not listed',
          entries: entry.value,
        ),
      );
    }

    return reports;
  }

  bool _isProjectEntry(LogEntry log, Project project) {
    if (log.category != Category.project) return false;
    final payload = log.payload;
    if (payload['projectId'] == project.id) return true;
    final projectName = (payload['projectName'] as String?)?.trim();
    return projectName != null &&
        projectName.toLowerCase() == project.name.trim().toLowerCase();
  }

  Map<Category, int> _categoryCounts() {
    final counts = {for (final category in Category.values) category: 0};
    for (final log in logs) {
      counts[log.category] = (counts[log.category] ?? 0) + 1;
    }
    return counts;
  }

  Map<DateTime, int> _entryCountsByDay() {
    final counts = <DateTime, int>{};
    for (final log in logs) {
      final day = _localDay(log.createdAt);
      counts[day] = (counts[day] ?? 0) + 1;
    }
    return counts;
  }

  Map<DateTime, List<LogEntry>> _logsByDay() {
    final byDay = <DateTime, List<LogEntry>>{};
    for (final log in logs) {
      final day = _localDay(log.createdAt);
      (byDay[day] ??= []).add(log);
    }
    return byDay;
  }

  Set<DateTime> get _trackedDays => logs.map((log) {
    return _localDay(log.createdAt);
  }).toSet();

  DateTime _localDay(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  DateTime _weekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - DateTime.monday));
  }

  int _sortLogsDesc(LogEntry a, LogEntry b) =>
      b.createdAt.compareTo(a.createdAt);

  String _paragraph(
    String text, {
    String styleId = 'Normal',
    String? alignment,
    bool bold = false,
    String? color,
    int? size,
    String? fontFamily,
    int before = 0,
    int after = 120,
    int leftIndent = 0,
  }) {
    final alignmentXml = alignment == null ? '' : '<w:jc w:val="$alignment"/>';
    final indentXml = leftIndent == 0
        ? ''
        : '<w:ind w:left="$leftIndent" w:hanging="0"/>';

    return '''
<w:p>
  <w:pPr>
    <w:pStyle w:val="$styleId"/>
    <w:spacing w:before="$before" w:after="$after" w:line="276" w:lineRule="auto"/>
    $alignmentXml
    $indentXml
  </w:pPr>
  ${_run(text, bold: bold, color: color, size: size, fontFamily: fontFamily)}
</w:p>
''';
  }

  String _run(
    String text, {
    bool bold = false,
    String? color,
    int? size,
    String? fontFamily,
  }) {
    final properties = StringBuffer();
    if (fontFamily != null) {
      properties.write(
        '<w:rFonts w:ascii="$fontFamily" w:hAnsi="$fontFamily"/>',
      );
    }
    if (bold) properties.write('<w:b/>');
    if (color != null) properties.write('<w:color w:val="$color"/>');
    if (size != null) {
      properties
        ..write('<w:sz w:val="$size"/>')
        ..write('<w:szCs w:val="$size"/>');
    }

    final normalized = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final pieces = normalized.split('\n');
    final value = StringBuffer();
    for (var i = 0; i < pieces.length; i++) {
      if (i > 0) value.write('<w:br/>');
      value.write('<w:t xml:space="preserve">${_xml(pieces[i])}</w:t>');
    }

    final runProperties = properties.isEmpty
        ? ''
        : '<w:rPr>$properties</w:rPr>';
    return '<w:r>$runProperties$value</w:r>';
  }

  String _divider() {
    return '''
<w:p>
  <w:pPr>
    <w:pBdr>
      <w:bottom w:val="single" w:sz="8" w:space="1" w:color="$_brandColor"/>
    </w:pBdr>
    <w:spacing w:after="220"/>
  </w:pPr>
</w:p>
''';
  }

  String _pageBreak() {
    return '<w:p><w:r><w:br w:type="page"/></w:r></w:p>';
  }

  String _sectionProperties() {
    return '''
<w:sectPr>
  <w:footerReference w:type="default" r:id="rIdFooter1"/>
  <w:pgSz w:w="12240" w:h="15840"/>
  <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>
</w:sectPr>
''';
  }

  String _footerXml() {
    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:p>
    <w:pPr>
      <w:pStyle w:val="Footer"/>
      <w:jc w:val="center"/>
    </w:pPr>
    <w:r>
      <w:rPr>
        <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>
        <w:sz w:val="18"/>
        <w:szCs w:val="18"/>
      </w:rPr>
      <w:t xml:space="preserve">Generated by DailyLog | Page </w:t>
    </w:r>
    <w:r><w:fldChar w:fldCharType="begin"/></w:r>
    <w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>
    <w:r><w:fldChar w:fldCharType="separate"/></w:r>
    <w:r><w:t>1</w:t></w:r>
    <w:r><w:fldChar w:fldCharType="end"/></w:r>
  </w:p>
</w:ftr>
''';
  }

  String _stylesXml() {
    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>
        <w:sz w:val="$_bodySize"/>
        <w:szCs w:val="$_bodySize"/>
      </w:rPr>
    </w:rPrDefault>
    <w:pPrDefault>
      <w:pPr>
        <w:spacing w:line="276" w:lineRule="auto"/>
      </w:pPr>
    </w:pPrDefault>
  </w:docDefaults>
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:spacing w:line="276" w:lineRule="auto"/>
    </w:pPr>
    <w:rPr>
      <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>
      <w:sz w:val="$_bodySize"/>
      <w:szCs w:val="$_bodySize"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:spacing w:before="240" w:after="120" w:line="276" w:lineRule="auto"/>
    </w:pPr>
    <w:rPr>
      <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>
      <w:b/>
      <w:color w:val="$_brandColor"/>
      <w:sz w:val="$_heading1Size"/>
      <w:szCs w:val="$_heading1Size"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:spacing w:before="180" w:after="100" w:line="276" w:lineRule="auto"/>
    </w:pPr>
    <w:rPr>
      <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>
      <w:b/>
      <w:color w:val="$_brandColor"/>
      <w:sz w:val="$_heading2Size"/>
      <w:szCs w:val="$_heading2Size"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Footer">
    <w:name w:val="Footer"/>
    <w:basedOn w:val="Normal"/>
    <w:rPr>
      <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>
      <w:sz w:val="18"/>
      <w:szCs w:val="18"/>
    </w:rPr>
  </w:style>
</w:styles>
''';
  }

  String _contentTypesXml() {
    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>
''';
  }

  String _rootRelationshipsXml() {
    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
''';
  }

  String _documentRelationshipsXml() {
    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rIdFooter1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/>
</Relationships>
''';
  }

  String _corePropertiesXml() {
    final timestamp = exportedAt.toUtc().toIso8601String();
    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>DailyLog Progress Report</dc:title>
  <dc:creator>DailyLog</dc:creator>
  <cp:lastModifiedBy>DailyLog</cp:lastModifiedBy>
  <dcterms:created xsi:type="dcterms:W3CDTF">$timestamp</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">$timestamp</dcterms:modified>
</cp:coreProperties>
''';
  }

  String _appPropertiesXml() {
    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>DailyLog</Application>
  <DocSecurity>0</DocSecurity>
  <ScaleCrop>false</ScaleCrop>
  <Company>DailyLog</Company>
  <LinksUpToDate>false</LinksUpToDate>
  <SharedDoc>false</SharedDoc>
  <HyperlinksChanged>false</HyperlinksChanged>
  <AppVersion>1.0</AppVersion>
</Properties>
''';
  }

  String _xml(String value) {
    return const HtmlEscape(HtmlEscapeMode.element).convert(value);
  }
}

class _TableCell {
  const _TableCell(this.text, {this.fill, this.color, this.bold = false});

  final String text;
  final String? fill;
  final String? color;
  final bool bold;
}

class _ProjectReport {
  const _ProjectReport({
    required this.name,
    required this.status,
    required this.entries,
  });

  final String name;
  final String status;
  final List<LogEntry> entries;
}

class _DocxArchive {
  final List<_DocxArchiveFile> _files = [];

  void add(String path, String contents) {
    _files.add(_DocxArchiveFile(path, utf8.encode(contents)));
  }

  Uint8List finish() {
    final output = BytesBuilder(copy: false);
    final centralDirectory = BytesBuilder(copy: false);
    final modified = DateTime.now();

    for (final file in _files) {
      final localHeaderOffset = output.length;
      final nameBytes = utf8.encode(file.path);
      final crc = _crc32(file.bytes);
      final dosTime = _dosTime(modified);
      final dosDate = _dosDate(modified);

      _writeUint32(output, 0x04034b50);
      _writeUint16(output, 20);
      _writeUint16(output, 0);
      _writeUint16(output, 0);
      _writeUint16(output, dosTime);
      _writeUint16(output, dosDate);
      _writeUint32(output, crc);
      _writeUint32(output, file.bytes.length);
      _writeUint32(output, file.bytes.length);
      _writeUint16(output, nameBytes.length);
      _writeUint16(output, 0);
      output
        ..add(nameBytes)
        ..add(file.bytes);

      _writeUint32(centralDirectory, 0x02014b50);
      _writeUint16(centralDirectory, 20);
      _writeUint16(centralDirectory, 20);
      _writeUint16(centralDirectory, 0);
      _writeUint16(centralDirectory, 0);
      _writeUint16(centralDirectory, dosTime);
      _writeUint16(centralDirectory, dosDate);
      _writeUint32(centralDirectory, crc);
      _writeUint32(centralDirectory, file.bytes.length);
      _writeUint32(centralDirectory, file.bytes.length);
      _writeUint16(centralDirectory, nameBytes.length);
      _writeUint16(centralDirectory, 0);
      _writeUint16(centralDirectory, 0);
      _writeUint16(centralDirectory, 0);
      _writeUint16(centralDirectory, 0);
      _writeUint32(centralDirectory, 0);
      _writeUint32(centralDirectory, localHeaderOffset);
      centralDirectory.add(nameBytes);
    }

    final centralOffset = output.length;
    final centralBytes = centralDirectory.takeBytes();
    output.add(centralBytes);

    _writeUint32(output, 0x06054b50);
    _writeUint16(output, 0);
    _writeUint16(output, 0);
    _writeUint16(output, _files.length);
    _writeUint16(output, _files.length);
    _writeUint32(output, centralBytes.length);
    _writeUint32(output, centralOffset);
    _writeUint16(output, 0);

    return output.takeBytes();
  }

  int _dosTime(DateTime date) {
    return (date.hour << 11) | (date.minute << 5) | (date.second ~/ 2);
  }

  int _dosDate(DateTime date) {
    final year = date.year < 1980 ? 1980 : date.year;
    return ((year - 1980) << 9) | (date.month << 5) | date.day;
  }

  int _crc32(List<int> data) {
    var crc = 0xffffffff;
    for (final byte in data) {
      crc = _crcTable[(crc ^ byte) & 0xff] ^ (crc >> 8);
    }
    return (crc ^ 0xffffffff) & 0xffffffff;
  }

  static final List<int> _crcTable = List<int>.generate(256, (index) {
    var crc = index;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc & 1) == 1 ? 0xedb88320 ^ (crc >> 1) : crc >> 1;
    }
    return crc;
  });

  static void _writeUint16(BytesBuilder output, int value) {
    final data = ByteData(2)..setUint16(0, value, Endian.little);
    output.add(data.buffer.asUint8List());
  }

  static void _writeUint32(BytesBuilder output, int value) {
    final data = ByteData(4)..setUint32(0, value, Endian.little);
    output.add(data.buffer.asUint8List());
  }
}

class _DocxArchiveFile {
  const _DocxArchiveFile(this.path, this.bytes);

  final String path;
  final List<int> bytes;
}
