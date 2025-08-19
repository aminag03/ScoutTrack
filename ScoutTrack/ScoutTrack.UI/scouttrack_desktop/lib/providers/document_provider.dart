import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/models/document.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

class DocumentProvider extends BaseProvider<Document, dynamic> {
  DocumentProvider(AuthProvider authProvider) : super(authProvider, 'Document');

  @override
  Document fromJson(dynamic json) {
    return Document.fromJson(json);
  }

  Future<void> downloadDocument(int documentId, String fileName) async {
    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.get(
        Uri.parse(
          "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/download/$documentId",
        ),
        headers: headers,
      );

      if (isValidResponse(response)) {
        String downloadsPath;
        if (Platform.isWindows) {
          downloadsPath = '${Platform.environment['USERPROFILE']}\\Downloads';
        } else if (Platform.isMacOS) {
          downloadsPath = '${Platform.environment['HOME']}/Downloads';
        } else {
          downloadsPath = '${Platform.environment['HOME']}/Downloads';
        }

        final downloadsDir = Directory(downloadsPath);
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception("Greška: Neuspješno preuzimanje dokumenta.");
      }
    });
  }

  Future<String> uploadDocument(File file) async {
    return await handleWithRefresh(() async {
      final headers = await createHeaders();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/upload",
        ),
      );

      request.headers.addAll(headers);

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(responseBody);

          if (data is String) {
            return data;
          } else {
            return data.toString();
          }
        } catch (e) {
          final cleanResponse = responseBody.replaceAll('"', '');
          return cleanResponse;
        }
      } else {
        throw Exception(
          "Greška: Neuspješno učitavanje dokumenta. Status: ${response.statusCode}",
        );
      }
    });
  }

  Future<bool> documentFileExists(int documentId) async {
    return await handleWithRefresh(() async {
      final headers = await createHeaders();
      final response = await http.get(
        Uri.parse(
          "${BaseProvider.baseUrl ?? "http://localhost:5164/"}$endpoint/$documentId/file-exists",
        ),
        headers: headers,
      );

      if (isValidResponse(response)) {
        return jsonDecode(response.body) as bool;
      } else {
        throw Exception("Greška: Neuspješno provjera postojanja datoteke.");
      }
    });
  }
}
