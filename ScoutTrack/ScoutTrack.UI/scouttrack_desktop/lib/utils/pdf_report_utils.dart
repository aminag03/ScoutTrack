import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:scouttrack_desktop/models/activity_type.dart';
import 'package:scouttrack_desktop/models/city.dart';
import 'package:scouttrack_desktop/models/equipment.dart';
import 'package:scouttrack_desktop/models/activity.dart';
import 'package:scouttrack_desktop/models/badge.dart';
import 'package:scouttrack_desktop/models/document.dart';
import 'package:scouttrack_desktop/models/member.dart';
import 'package:scouttrack_desktop/models/troop.dart';
import 'package:scouttrack_desktop/models/member_badge.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';

class PdfReportUtils {
  static String _convertToAscii(String text) {
    return text
        .replaceAll('š', 's')
        .replaceAll('Š', 'S')
        .replaceAll('č', 'c')
        .replaceAll('Č', 'C')
        .replaceAll('ć', 'c')
        .replaceAll('Ć', 'C')
        .replaceAll('ž', 'z')
        .replaceAll('Ž', 'Z')
        .replaceAll('đ', 'dj')
        .replaceAll('Đ', 'Dj');
  }

  static Future<String> generateActivityTypeReport(
    List<ActivityType> activityTypes, {
    Map<String, dynamic>? filters,
  }) async {
    final pdf = pw.Document();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          _buildHeader('IZVJESTAJ - TIPOVI AKTIVNOSTI', filters),
          _buildActivityTypeTable(activityTypes),
        ],
      ),
    );

    return await _savePdf(pdf, 'tipovi_aktivnosti_izvjestaj_$timestamp.pdf');
  }

  static Future<String> generateCityReport(
    List<City> cities, {
    Map<String, dynamic>? filters,
  }) async {
    final pdf = pw.Document();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          _buildHeader('IZVJESTAJ - GRADOVI', filters),
          _buildCityTable(cities),
        ],
      ),
    );

    return await _savePdf(pdf, 'gradovi_izvjestaj_$timestamp.pdf');
  }

  static Future<String> generateEquipmentReport(
    List<Equipment> equipment, {
    Map<String, dynamic>? filters,
    Map<int, String>? troopNames,
  }) async {
    final pdf = pw.Document();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          _buildHeader('IZVJESTAJ - OPREMA', filters),
          _buildEquipmentTable(equipment, troopNames),
        ],
      ),
    );

    return await _savePdf(pdf, 'oprema_izvjestaj_$timestamp.pdf');
  }

  static Future<String> generateActivityReport(
    List<Activity> activities, {
    Map<String, dynamic>? filters,
  }) async {
    final pdf = pw.Document();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());

    final Map<int, String> troopIdToName = {};
    for (final activity in activities) {
      if (activity.troopName.isNotEmpty) {
        troopIdToName[activity.troopId] = activity.troopName;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          _buildHeader('IZVJESTAJ - AKTIVNOSTI', filters, null, troopIdToName),
          _buildActivityTable(activities),
        ],
      ),
    );

    return await _savePdf(pdf, 'aktivnosti_izvjestaj_$timestamp.pdf');
  }

  static Future<String> generateBadgeReport(
    List<Badge> badges, {
    Map<String, dynamic>? filters,
  }) async {
    final pdf = pw.Document();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          _buildHeader('IZVJESTAJ - VJESTARSTVA', filters),
          _buildBadgeTable(badges),
        ],
      ),
    );

    return await _savePdf(pdf, 'vjestarstva_izvjestaj_$timestamp.pdf');
  }

  static Future<String> generateDocumentReport(
    List<Document> documents, {
    Map<String, dynamic>? filters,
  }) async {
    final pdf = pw.Document();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          _buildHeader('IZVJESTAJ - DOKUMENTI', filters),
          _buildDocumentTable(documents),
        ],
      ),
    );

    return await _savePdf(pdf, 'dokumenti_izvjestaj_$timestamp.pdf');
  }

  static Future<String> generateMemberReport(
    List<Member> members, {
    Map<String, dynamic>? filters,
  }) async {
    final pdf = pw.Document();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());

    final Map<int, String> troopIdToName = {};
    for (final member in members) {
      if (member.troopName.isNotEmpty) {
        troopIdToName[member.troopId] = member.troopName;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          _buildHeader('IZVJESTAJ - CLANOVI', filters, null, troopIdToName),
          _buildMemberTable(members),
        ],
      ),
    );

    return await _savePdf(pdf, 'clanovi_izvjestaj_$timestamp.pdf');
  }

  static Future<String> generateTroopReport(
    List<Troop> troops, {
    Map<String, dynamic>? filters,
  }) async {
    final pdf = pw.Document();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          _buildHeader('IZVJESTAJ - ODREDI', filters),
          _buildTroopTable(troops),
        ],
      ),
    );

    return await _savePdf(pdf, 'odredi_izvjestaj_$timestamp.pdf');
  }

  static Future<String> generateMemberBadgeReport(
    List<MemberBadge> memberBadges, {
    Map<String, dynamic>? filters,
    Map<int, String>? memberTroopNames,
  }) async {
    final pdf = pw.Document();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());

    final Map<int, String> badgeIdToName = {};
    for (final memberBadge in memberBadges) {
      badgeIdToName[memberBadge.badgeId] = memberBadge.badgeName;
    }

    final Map<int, String> troopIdToName = {};
    if (memberTroopNames != null &&
        filters != null &&
        filters.containsKey('TroopId')) {
      final troopId = filters['TroopId'] as int;
      final memberBadge = memberBadges.firstWhere(
        (mb) => memberTroopNames[mb.memberId] != null,
        orElse: () => memberBadges.first,
      );
      if (memberTroopNames[memberBadge.memberId] != null) {
        troopIdToName[troopId] = memberTroopNames[memberBadge.memberId]!;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          _buildHeader(
            'IZVJESTAJ - VJESTARSTVA CLANOVA',
            filters,
            badgeIdToName,
            troopIdToName,
            memberTroopNames,
          ),
          _buildMemberBadgeTable(memberBadges),
        ],
      ),
    );

    return await _savePdf(pdf, 'vjestarstva_clanova_izvjestaj_$timestamp.pdf');
  }

  static pw.Widget _buildHeader(
    String title,
    Map<String, dynamic>? filters, [
    Map<int, String>? badgeIdToName,
    Map<int, String>? troopIdToName,
    Map<int, String>? memberTroopNames,
  ]) {
    return pw.Header(
      level: 0,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.helvetica(),
                  fontFallback: [pw.Font.times()],
                ),
              ),
              pw.Text(
                'Generisano: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 10,
                  font: pw.Font.helvetica(),
                  fontFallback: [pw.Font.times()],
                ),
              ),
            ],
          ),
          if (filters != null && filters.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _buildFiltersSection(
              filters,
              badgeIdToName,
              troopIdToName,
              memberTroopNames,
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildFiltersSection(
    Map<String, dynamic> filters, [
    Map<int, String>? badgeIdToName,
    Map<int, String>? troopIdToName,
    Map<int, String>? memberTroopNames,
  ]) {
    final List<pw.Widget> filterRows = [];

    if (filters.containsKey('FTS') &&
        filters['FTS'] != null &&
        filters['FTS'].toString().isNotEmpty) {
      filterRows.add(
        _buildFilterRow('Pretraga', _convertToAscii(filters['FTS'].toString())),
      );
    }

    if (filters.containsKey('CityName') && filters['CityName'] != null) {
      filterRows.add(
        _buildFilterRow(
          'Grad',
          _convertToAscii(filters['CityName'].toString()),
        ),
      );
    }

    if (filters.containsKey('TroopName') &&
        filters['TroopName'] != null &&
        !filters.containsKey('TroopId')) {
      filterRows.add(
        _buildFilterRow(
          'Odred',
          _convertToAscii(filters['TroopName'].toString()),
        ),
      );
    }

    if (filters.containsKey('ActivityTypeName') &&
        filters['ActivityTypeName'] != null) {
      filterRows.add(
        _buildFilterRow(
          'Tip aktivnosti',
          _convertToAscii(filters['ActivityTypeName'].toString()),
        ),
      );
    }

    if (filters.containsKey('Gender') && filters['Gender'] != null) {
      if (filters.containsKey('GenderText') && filters['GenderText'] != null) {
        filterRows.add(
          _buildFilterRow(
            'Spol',
            _convertToAscii(filters['GenderText'].toString()),
          ),
        );
      } else {
        final genderText = filters['Gender'] == 0 ? 'Muski' : 'Zenski';
        filterRows.add(_buildFilterRow('Spol', genderText));
      }
    }

    if (filters.containsKey('OrderBy') &&
        filters['OrderBy'] != null &&
        filters['OrderBy'].toString().isNotEmpty) {
      final orderByText = _getOrderByDisplayText(filters['OrderBy'].toString());
      filterRows.add(_buildFilterRow('Sortiranje', orderByText));
    }

    if (filters.containsKey('IsActive') && filters['IsActive'] != null) {
      final activeText = filters['IsActive'] == true ? 'Aktivni' : 'Neaktivni';
      filterRows.add(_buildFilterRow('Status', activeText));
    }

    if (filters.containsKey('IsGlobal') && filters['IsGlobal'] != null) {
      final globalText = filters['IsGlobal'] == true ? 'Globalna' : 'Lokalna';
      filterRows.add(_buildFilterRow('Tip opreme', globalText));
    }

    if (filters.containsKey('IsPrivate') && filters['IsPrivate'] != null) {
      final privateText = filters['IsPrivate'] == true ? 'Privatne' : 'Javne';
      filterRows.add(_buildFilterRow('Privatnost', privateText));
    }

    if (filters.containsKey('ActivityState') &&
        filters['ActivityState'] != null &&
        filters['ActivityState'].toString().isNotEmpty) {
      final stateText = _getActivityStateDisplayText(
        filters['ActivityState'].toString(),
      );
      filterRows.add(_buildFilterRow('Status aktivnosti', stateText));
    }

    if (filters.containsKey('BadgeId') && filters['BadgeId'] != null) {
      final badgeId = filters['BadgeId'] as int;
      final badgeName = badgeIdToName?[badgeId] ?? 'Vjestarstvo ID: $badgeId';
      filterRows.add(
        _buildFilterRow('Vjestarstvo', _convertToAscii(badgeName)),
      );
    }

    if (filters.containsKey('Status') && filters['Status'] != null) {
      final statusText = filters['Status'] == 0 ? 'U toku' : 'Zavrseno';
      filterRows.add(_buildFilterRow('Status vjestarstva', statusText));
    }

    if (filters.containsKey('TroopId') && filters['TroopId'] != null) {
      final troopId = filters['TroopId'] as int;
      String troopName = 'Odred ID: $troopId';

      if (troopIdToName?[troopId] != null) {
        troopName = troopIdToName![troopId]!;
      } else if (memberTroopNames != null && memberTroopNames.isNotEmpty) {
        troopName = memberTroopNames.values.first;
      }

      filterRows.add(_buildFilterRow('Odred', _convertToAscii(troopName)));
    }

    if (filterRows.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Primijenjeni filteri:',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              font: pw.Font.helvetica(),
              fontFallback: [pw.Font.times()],
            ),
          ),
          pw.SizedBox(height: 4),
          ...filterRows,
        ],
      ),
    );
  }

  static pw.Widget _buildFilterRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 8,
                font: pw.Font.helvetica(),
                fontFallback: [pw.Font.times()],
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 8,
                font: pw.Font.helvetica(),
                fontFallback: [pw.Font.times()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildActivityTypeTable(List<ActivityType> activityTypes) {
    return pw.Table.fromTextArray(
      headers: ['Naziv', 'Opis', 'Broj aktivnosti', 'Vrijeme kreiranja'],
      data: activityTypes
          .map(
            (type) => [
              _convertToAscii(type.name),
              _convertToAscii(
                type.description.isNotEmpty ? type.description : '-',
              ),
              '${type.activityCount}',
              formatDateTime(type.createdAt),
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      cellStyle: pw.TextStyle(
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 20,
      cellPadding: const pw.EdgeInsets.all(2),
      columnWidths: {
        0: const pw.FixedColumnWidth(120),
        1: const pw.FixedColumnWidth(200),
        2: const pw.FixedColumnWidth(100),
        3: const pw.FixedColumnWidth(100),
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
      },
    );
  }

  static pw.Widget _buildCityTable(List<City> cities) {
    return pw.Table.fromTextArray(
      headers: ['Naziv', 'Broj odreda', 'Broj clanova', 'Vrijeme kreiranja'],
      data: cities
          .map(
            (city) => [
              _convertToAscii(city.name),
              '${city.troopCount}',
              '${city.memberCount}',
              formatDateTime(city.createdAt),
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      cellStyle: pw.TextStyle(
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 20,
      cellPadding: const pw.EdgeInsets.all(2),
      columnWidths: {
        0: const pw.FixedColumnWidth(200),
        1: const pw.FixedColumnWidth(100),
        2: const pw.FixedColumnWidth(100),
        3: const pw.FixedColumnWidth(100),
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
      },
    );
  }

  static pw.Widget _buildEquipmentTable(
    List<Equipment> equipment,
    Map<int, String>? troopNames,
  ) {
    return pw.Table.fromTextArray(
      headers: [
        'Naziv',
        'Opis',
        'Status',
        'Kreirao odred',
        'Vrijeme kreiranja',
      ],
      data: equipment
          .map(
            (eq) => [
              _convertToAscii(eq.name),
              _convertToAscii(eq.description.isNotEmpty ? eq.description : '-'),
              eq.isGlobal ? 'Globalna' : 'Lokalna',
              eq.createdByTroopId != null
                  ? _convertToAscii(
                      troopNames![eq.createdByTroopId] ??
                          'Odred ${eq.createdByTroopId}',
                    )
                  : '-',
              formatDateTime(eq.createdAt),
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      cellStyle: pw.TextStyle(
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 20,
      cellPadding: const pw.EdgeInsets.all(2),
      columnWidths: {
        0: const pw.FixedColumnWidth(100),
        1: const pw.FixedColumnWidth(150),
        2: const pw.FixedColumnWidth(80),
        3: const pw.FixedColumnWidth(100),
        4: const pw.FixedColumnWidth(100),
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
      },
    );
  }

  static pw.Widget _buildBadgeTable(List<Badge> badges) {
    return pw.Table.fromTextArray(
      headers: ['Naziv', 'Opis', 'Ukupno clanova', 'Zavrseno', 'U toku'],
      data: badges
          .map(
            (badge) => [
              _convertToAscii(badge.name),
              _convertToAscii(
                badge.description.isNotEmpty ? badge.description : '-',
              ),
              '${badge.totalMemberBadges}',
              '${badge.completedMemberBadges}',
              '${badge.inProgressMemberBadges}',
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      cellStyle: pw.TextStyle(
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 20,
      cellPadding: const pw.EdgeInsets.all(2),
      columnWidths: {
        0: const pw.FixedColumnWidth(120),
        1: const pw.FixedColumnWidth(200),
        2: const pw.FixedColumnWidth(100),
        3: const pw.FixedColumnWidth(80),
        4: const pw.FixedColumnWidth(80),
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
      },
    );
  }

  static pw.Widget _buildActivityTable(List<Activity> activities) {
    return pw.Table.fromTextArray(
      headers: [
        'Naslov',
        'Lokacija',
        'Opis',
        'Tip aktivnosti',
        'Odred',
        'Vrijeme pocetka',
        'Vrijeme zavrsetka',
        'Status',
        'Vrijeme kreiranja',
      ],
      data: activities
          .map(
            (activity) => [
              _convertToAscii(activity.title),
              _convertToAscii(
                activity.locationName.isNotEmpty ? activity.locationName : '-',
              ),
              _convertToAscii(
                activity.description.isNotEmpty ? activity.description : '-',
              ),
              _convertToAscii(
                activity.activityTypeName.isNotEmpty
                    ? activity.activityTypeName
                    : '-',
              ),
              _convertToAscii(
                activity.troopName.isNotEmpty ? activity.troopName : '-',
              ),
              activity.startTime != null
                  ? formatDateTime(activity.startTime!)
                  : '-',
              activity.endTime != null
                  ? formatDateTime(activity.endTime!)
                  : '-',
              _getActivityStateText(activity.activityState),
              formatDateTime(activity.createdAt),
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      cellStyle: pw.TextStyle(
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 20,
      cellPadding: const pw.EdgeInsets.all(2),
      columnWidths: {
        0: const pw.FixedColumnWidth(100),
        1: const pw.FixedColumnWidth(100),
        2: const pw.FixedColumnWidth(150),
        3: const pw.FixedColumnWidth(100),
        4: const pw.FixedColumnWidth(100),
        5: const pw.FixedColumnWidth(100),
        6: const pw.FixedColumnWidth(100),
        7: const pw.FixedColumnWidth(80),
        8: const pw.FixedColumnWidth(100),
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
        5: pw.Alignment.center,
        6: pw.Alignment.center,
        7: pw.Alignment.center,
        8: pw.Alignment.center,
      },
    );
  }

  static pw.Widget _buildDocumentTable(List<Document> documents) {
    return pw.Table.fromTextArray(
      headers: ['Naslov', 'Dodao admin', 'Vrijeme kreiranja'],
      data: documents
          .map(
            (doc) => [
              _convertToAscii(doc.title),
              _convertToAscii(
                doc.adminFullName.isNotEmpty ? doc.adminFullName : '-',
              ),
              formatDateTime(doc.createdAt),
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      cellStyle: pw.TextStyle(
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 20,
      cellPadding: const pw.EdgeInsets.all(2),
      columnWidths: {
        0: const pw.FixedColumnWidth(200),
        1: const pw.FixedColumnWidth(150),
        2: const pw.FixedColumnWidth(100),
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
      },
    );
  }

  static pw.Widget _buildMemberTable(List<Member> members) {
    return pw.Table.fromTextArray(
      headers: [
        'Ime',
        'Prezime',
        'Korisnicko ime',
        'Grad',
        'Odred',
        'Datum rodjenja',
        'Spol',
        'Aktivan',
        'Vrijeme kreiranja',
      ],
      data: members
          .map(
            (member) => [
              _convertToAscii(member.firstName),
              _convertToAscii(member.lastName),
              _convertToAscii(member.username),
              _convertToAscii(member.cityName),
              _convertToAscii(
                member.troopName.isNotEmpty ? member.troopName : '-',
              ),
              formatDate(member.birthDate),
              member.gender == 0 ? 'Muski' : 'Zenski',
              member.isActive ? 'Da' : 'Ne',
              formatDateTime(member.createdAt),
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      cellStyle: pw.TextStyle(
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 20,
      cellPadding: const pw.EdgeInsets.all(2),
      columnWidths: {
        0: const pw.FixedColumnWidth(80),
        1: const pw.FixedColumnWidth(100),
        2: const pw.FixedColumnWidth(120),
        3: const pw.FixedColumnWidth(100),
        4: const pw.FixedColumnWidth(100),
        5: const pw.FixedColumnWidth(100),
        6: const pw.FixedColumnWidth(60),
        7: const pw.FixedColumnWidth(60),
        8: const pw.FixedColumnWidth(100),
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
        5: pw.Alignment.center,
        6: pw.Alignment.center,
        7: pw.Alignment.center,
        8: pw.Alignment.center,
      },
    );
  }

  static pw.Widget _buildTroopTable(List<Troop> troops) {
    return pw.Table.fromTextArray(
      headers: [
        'Naziv',
        'Korisnicko ime',
        'E-mail',
        'Grad',
        'Broj clanova',
        'Datum osnivanja',
        'Aktivan',
        'Vrijeme kreiranja',
      ],
      data: troops
          .map(
            (troop) => [
              _convertToAscii(troop.name),
              _convertToAscii(troop.username),
              _convertToAscii(troop.email),
              _convertToAscii(troop.cityName.isNotEmpty ? troop.cityName : '-'),
              '${troop.memberCount}',
              formatDate(troop.foundingDate),
              troop.isActive ? 'Da' : 'Ne',
              formatDateTime(troop.createdAt),
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      cellStyle: pw.TextStyle(
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 20,
      cellPadding: const pw.EdgeInsets.all(2),
      columnWidths: {
        0: const pw.FixedColumnWidth(120),
        1: const pw.FixedColumnWidth(120),
        2: const pw.FixedColumnWidth(120),
        3: const pw.FixedColumnWidth(100),
        4: const pw.FixedColumnWidth(100),
        5: const pw.FixedColumnWidth(100),
        6: const pw.FixedColumnWidth(60),
        7: const pw.FixedColumnWidth(100),
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
        5: pw.Alignment.center,
        6: pw.Alignment.center,
        7: pw.Alignment.center,
      },
    );
  }

  static pw.Widget _buildMemberBadgeTable(List<MemberBadge> memberBadges) {
    return pw.Table.fromTextArray(
      headers: [
        'Clan',
        'Vjestarstvo',
        'Status',
        'Datum pocetka',
        'Datum zavrsetka',
      ],
      data: memberBadges
          .map(
            (memberBadge) => [
              _convertToAscii(memberBadge.memberFullName),
              _convertToAscii(memberBadge.badgeName),
              memberBadge.status == 0 ? 'U toku' : 'Zavrseno',
              formatDateTime(memberBadge.createdAt),
              memberBadge.completedAt != null
                  ? formatDateTime(memberBadge.completedAt!)
                  : '-',
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      cellStyle: pw.TextStyle(
        font: pw.Font.helvetica(),
        fontFallback: [pw.Font.times()],
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 20,
      cellPadding: const pw.EdgeInsets.all(2),
      columnWidths: {
        0: const pw.FixedColumnWidth(150),
        1: const pw.FixedColumnWidth(180),
        2: const pw.FixedColumnWidth(100),
        3: const pw.FixedColumnWidth(120),
        4: const pw.FixedColumnWidth(120),
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
      },
    );
  }

  static String _getActivityStateText(String state) {
    switch (state) {
      case 'DraftActivityState':
        return 'Nacrt';
      case 'RegistrationsOpenActivityState':
        return 'Prijave otvorene';
      case 'RegistrationsClosedActivityState':
        return 'Prijave zatvorene';
      case 'FinishedActivityState':
        return 'Zavrsena';
      case 'CancelledActivityState':
        return 'Otkazana';
      default:
        return state;
    }
  }

  static String _getOrderByDisplayText(String orderBy) {
    final lowerOrderBy = orderBy.toLowerCase();

    if (lowerOrderBy == 'firstname') {
      return 'Ime (A-Z)';
    }
    if (lowerOrderBy == '-firstname') {
      return 'Ime (Z-A)';
    }

    if (lowerOrderBy == 'lastname') {
      return 'Prezime (A-Z)';
    }
    if (lowerOrderBy == '-lastname') {
      return 'Prezime (Z-A)';
    }

    if (lowerOrderBy == 'name') {
      return 'Naziv (A-Z)';
    }
    if (lowerOrderBy == '-name') {
      return 'Naziv (Z-A)';
    }

    if (lowerOrderBy == 'title') {
      return 'Naslov (A-Z)';
    }
    if (lowerOrderBy == '-title') {
      return 'Naslov (Z-A)';
    }

    if (lowerOrderBy == 'membercount') {
      return 'Broj clanova (rastuce)';
    }
    if (lowerOrderBy == '-membercount') {
      return 'Broj clanova (opadajuce)';
    }

    if (lowerOrderBy == 'foundingdate') {
      return 'Datum osnivanja (najstariji)';
    }
    if (lowerOrderBy == '-foundingdate') {
      return 'Datum osnivanja (najnoviji)';
    }

    if (lowerOrderBy == 'birthdate') {
      return 'Datum rodjenja (najstariji)';
    }
    if (lowerOrderBy == '-birthdate') {
      return 'Datum rodjenja (najnoviji)';
    }

    if (lowerOrderBy == 'starttime') {
      return 'Vrijeme pocetka (najranije)';
    }
    if (lowerOrderBy == '-starttime') {
      return 'Vrijeme pocetka (najkasnije)';
    }

    if (lowerOrderBy == 'endtime') {
      return 'Vrijeme zavrsetka (najranije)';
    }
    if (lowerOrderBy == '-endtime') {
      return 'Vrijeme zavrsetka (najkasnije)';
    }

    if (lowerOrderBy == 'createdat') {
      return 'Datum kreiranja (starije-novije)';
    }
    if (lowerOrderBy == '-createdat') {
      return 'Datum kreiranja (novije-starije)';
    }

    if (lowerOrderBy == 'updatedat') {
      return 'Datum izmjene (starije-novije)';
    }
    if (lowerOrderBy == '-updatedat') {
      return 'Datum izmjene (novije-starije)';
    }

    if (lowerOrderBy == 'memberfirstname') {
      return 'Ime clana (A-Z)';
    }
    if (lowerOrderBy == '-memberfirstname') {
      return 'Ime clana (Z-A)';
    }

    if (lowerOrderBy == 'badgename') {
      return 'Naziv vjestarstva (A-Z)';
    }
    if (lowerOrderBy == '-badgename') {
      return 'Naziv vjestarstva (Z-A)';
    }

    if (lowerOrderBy == 'completedat') {
      return 'Datum zavrsetka (najstariji)';
    }
    if (lowerOrderBy == '-completedat') {
      return 'Datum zavrsetka (najnoviji)';
    }

    if (lowerOrderBy == 'status') {
      return 'Status (U toku → Zavrseno)';
    }
    if (lowerOrderBy == '-status') {
      return 'Status (Zavrseno → U toku)';
    }

    return orderBy;
  }

  static String _getActivityStateDisplayText(String state) {
    switch (state) {
      case 'DraftActivityState':
        return 'Nacrt';
      case 'RegistrationsOpenActivityState':
        return 'Prijave otvorene';
      case 'RegistrationsClosedActivityState':
        return 'Prijave zatvorene';
      case 'FinishedActivityState':
        return 'Zavrsena';
      case 'CancelledActivityState':
        return 'Otkazana';
      default:
        return state;
    }
  }

  static Future<String> _savePdf(pw.Document pdf, String fileName) async {
    try {
      Directory? downloadsDir;
      if (Platform.isWindows) {
        downloadsDir = Directory(
          '${Platform.environment['USERPROFILE']}\\Downloads',
        );
      } else if (Platform.isMacOS) {
        downloadsDir = Directory('${Platform.environment['HOME']}/Downloads');
      } else if (Platform.isLinux) {
        downloadsDir = Directory('${Platform.environment['HOME']}/Downloads');
      }

      if (downloadsDir == null || !downloadsDir.existsSync()) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      final file = File('${downloadsDir.path}/$fileName');
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);

      return file.path;
    } catch (e) {
      throw Exception('Greska pri spremanju PDF-a: $e');
    }
  }
}
