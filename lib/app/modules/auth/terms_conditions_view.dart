import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({Key? key}) : super(key: key);

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool isLoading = true;
  String errorMessage = '';
  String? localFilePath;
  String? pdfUrl;
  String? title;

  @override
  void initState() {
    super.initState();
    _loadArguments();
    _downloadAndDisplayPdf();
  }

  void _loadArguments() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      pdfUrl = arguments['pdf_url'];
      title = arguments['title'] ?? 'document'.tr;
    }

    if (pdfUrl == null) {
      setState(() {
        errorMessage = 'no_pdf_url_provided'.tr;
        isLoading = false;
      });
    }
  }

  Future<void> _downloadAndDisplayPdf() async {
    if (pdfUrl == null) return;
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Generate a unique filename based on URL hash
      final urlHash = pdfUrl!.hashCode.toString();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/pdf_$urlHash.pdf');

      // Check if file already exists locally
      if (await file.exists()) {
        print('PDF already downloaded, using cached version');
        setState(() {
          localFilePath = file.path;
          isLoading = false;
        });
        return;
      }

      print('Downloading PDF from URL: $pdfUrl');
      // Download PDF file
      final response = await http.get(Uri.parse(pdfUrl!));

      if (response.statusCode == 200) {
        // Write PDF bytes to file
        await file.writeAsBytes(response.bodyBytes);
        print('PDF downloaded and saved to: ${file.path}');

        setState(() {
          localFilePath = file.path;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'failed_to_load_document'.tr + ': ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'error_loading_document'.tr + ': ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'document'.tr),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'loading_document'.tr,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'error_loading_document'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _downloadAndDisplayPdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text('retry'.tr),
            ),
          ],
        ),
      );
    }

    if (localFilePath != null) {
      return PDFView(
        filePath: localFilePath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: true,
        pageSnap: true,
        onError: (error) {
          setState(() {
            errorMessage = error.toString();
          });
        },
      );
    }

    return Center(
      child: Text(
        'no_document_available'.tr,
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
