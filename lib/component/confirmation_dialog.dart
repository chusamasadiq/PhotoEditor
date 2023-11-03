import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

Future<T?> showConfirmationDialog<T>(
  BuildContext context, {
  required String title,
  String? desc,
  String leftText = "Cancel",
  String rightText = "Discard",
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (desc != null)
              Text(
                desc,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              leftText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              rightText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white),
            ),
          )
        ],
      );
    },
  );
}

showProgressDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    },
  );
}

hideProgressDialog(BuildContext context) {
  Navigator.pop(context);
}

showDialogBox(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> captureAndSaveImage(
    BuildContext context, ScreenshotController screenshotController) async {
  showProgressDialog(context);

  // Request storage permission
  if (await Permission.storage.request().isGranted) {
    final image = await screenshotController.capture(
      delay: const Duration(milliseconds: 200),
    );

    if (image != null) {
      String customDirectoryPath = '/storage/emulated/0/Download/';

      final directory = Directory(customDirectoryPath);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final file = File('${directory.path}/screenshot.png');
      await file.writeAsBytes(image);
      hideProgressDialog(context);
      showDialogBox(context, 'Image downloaded successfully...');
    } else {
      hideProgressDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture the image'),
        ),
      );
    }
  } else {
    hideProgressDialog(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Storage permission denied'),
      ),
    );
  }
}
