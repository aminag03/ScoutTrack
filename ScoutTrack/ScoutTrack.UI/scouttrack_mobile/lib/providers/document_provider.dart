import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:scouttrack_mobile/providers/base_provider.dart';
import 'package:scouttrack_mobile/models/document.dart';
import 'package:scouttrack_mobile/providers/auth_provider.dart';

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
        Directory? downloadsDir;
        if (Platform.isAndroid) {
          downloadsDir = Directory('/storage/emulated/0/Download');
          if (!await downloadsDir.exists()) {
            downloadsDir = await getExternalStorageDirectory();
          }
        } else if (Platform.isIOS) {
          downloadsDir = await getApplicationDocumentsDirectory();
        } else {
          downloadsDir = await getApplicationDocumentsDirectory();
        }

        if (downloadsDir == null || !await downloadsDir.exists()) {
          downloadsDir = await getApplicationDocumentsDirectory();
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
