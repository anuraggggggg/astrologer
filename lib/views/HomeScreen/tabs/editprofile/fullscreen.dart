import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show basename;
import 'package:url_launcher/url_launcher_string.dart';
// If you want to open local files, add `open_file` package and uncomment below:
// import 'package:open_file/open_file.dart';

class FullScreenMediaPage extends StatelessWidget {
  final File? localFile;
  final String? url;
  final String title;

  const FullScreenMediaPage({super.key, this.localFile, this.url, this.title = 'Document'});

  bool _isPdf(String? path) {
    if (path == null) return false;
    return path.toLowerCase().endsWith('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final isLocalPdf = _isPdf(localFile?.path);
    final isRemotePdf = _isPdf(url);
    final isPdfFile = isLocalPdf || isRemotePdf;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: isPdfFile ? _buildPdfView(context) : _buildImageView(context),
        ),
      ),
    );
  }

  Widget _buildImageView(BuildContext context) {
    final Widget content;
    if (localFile != null) {
      content = Image.file(localFile!, fit: BoxFit.contain);
    } else if (url != null && url!.isNotEmpty) {
      content = Image.network(url!, fit: BoxFit.contain, errorBuilder: (_, __, ___) {
        return const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.white70));
      });
    } else {
      content = const Center(child: Icon(Icons.image_not_supported, size: 60, color: Colors.white70));
    }

    return InteractiveViewer(
      panEnabled: true,
      scaleEnabled: true,
      minScale: 0.5,
      maxScale: 4.0,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        child: content,
      ),
    );
  }

  Widget _buildPdfView(BuildContext context) {
    // Show only a friendly name (filename) and an 'Open PDF' button. No raw URL displayed.
    final displayName = localFile != null ? basename(localFile!.path) : (title.isNotEmpty ? title : 'PDF Document');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.picture_as_pdf, size: 96, color: Colors.redAccent),
        const SizedBox(height: 16),
        Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () async {
            // If remote URL present, open it in external app/browser
            if (url != null && url!.isNotEmpty) {
              try {
                final ok = await launchUrlString(url!, mode: LaunchMode.externalApplication);
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open PDF URL.')));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening PDF: $e')));
              }
              return;
            }

            // If local file present, try to open it using open_file package.
            if (localFile != null) {
              // If you have `open_file` package added, uncomment below and import it:
              // final res = await OpenFile.open(localFile!.path);
              // if (res.type != ResultType.done) { show snack ... }
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('To open local PDF directly, add `open_file` package and use it here.'),
              ));
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No PDF available to open.')));
          },
          icon: const Icon(Icons.open_in_new),
          label: const Text('Open PDF'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          // child: Text(
          //   'PDF will open in external app. Local-file opening requires `open_file` package.',
          //   textAlign: TextAlign.center,
          //   style: TextStyle(color: Colors.white70),
          // ),
        )
      ],
    );
  }
}
