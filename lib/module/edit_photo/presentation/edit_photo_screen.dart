import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_editor/module/edit_photo/model/dragable_widget_child.dart';
import 'package:photo_editor/module/edit_photo/presentation/cubit/edit_photo_cubit.dart';
import 'package:photo_editor/module/edit_photo/presentation/pages/add_text_layout.dart';
import 'package:photo_editor/module/edit_photo/presentation/widget/dragable_widget.dart';
import 'package:photo_editor/module/edit_photo/presentation/widget/edit_photo_widget.dart';
import 'package:photo_editor/module/edit_photo/presentation/widget/menu_icon_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../component/confirmation_dialog.dart';

class EditPhotoScreen extends StatelessWidget {
  final ImageProvider image;

  const EditPhotoScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditPhotoCubit(),
      child: EditPhotoLayout(image: image),
    );
  }
}

class EditPhotoLayout extends StatefulWidget {
  final ImageProvider image;

  const EditPhotoLayout({super.key, required this.image});

  @override
  State<EditPhotoLayout> createState() => _EditPhotoLayoutState();
}

class _EditPhotoLayoutState extends State<EditPhotoLayout> {
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditPhotoCubit, EditPhotoState>(
      listener: (context, state) {},
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            Screenshot(
              controller: screenshotController,
              child: EditPhotoWidget(photo: widget.image),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              child: MenuIconWidget(
                onTap: () async {
                  final result = await showConfirmationDialog(
                    context,
                    title: "Discard Edits",
                    desc:
                        "Are you sure want to Exit ? You'll lose all the edits you've made",
                  );
                  if (result == null) return;

                  if (result) {
                    if (!mounted) return;
                    Navigator.pop(context);
                  }
                },
                icon: Icons.arrow_back_ios_new_rounded,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 20,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MenuIconWidget(
                    onTap: () async {
                      final status = await Permission.storage.request();

                      if (status.isGranted) {
                        String fileName =
                            DateTime.now().microsecondsSinceEpoch.toString() +
                                '.png'; // Add ".png" extension
                        const path = '/storage/emulated/0/Download';
                        try {
                          screenshotController.captureAndSave(
                            path,
                            fileName: fileName,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Screenshot saved to $path/$fileName'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Failed to capture and save screenshot: $e'),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Permission to access storage denied.'),
                          ),
                        );
                      }
                    },
                    icon: CupertinoIcons.cloud_download,
                  ),
                  const SizedBox(width: 16),
                  MenuIconWidget(
                    onTap: () async {
                      showProgressDialog(context);
                      final image = await screenshotController.capture(
                        delay: const Duration(milliseconds: 200),
                      );
                      if (image != null) {
                        // Create a temporary file to save the image
                        final tempDir = await getTemporaryDirectory();
                        final file = File('${tempDir.path}/screenshot.png');
                        // Write the captured image data to the file
                        await file.writeAsBytes(image);
                        hideProgressDialog(context);
                        // Share the file using the share package
                        await Share.shareXFiles([XFile(file.path)]);
                      }
                    },
                    icon: CupertinoIcons.share,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              bottom: MediaQuery.of(context).padding.bottom + 20,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BlocBuilder<EditPhotoCubit, EditPhotoState>(
                        buildWhen: (p, c) {
                          return p.editState != c.editState ||
                              p.opacityLayer != c.opacityLayer;
                        },
                        builder: (context, state) {
                          return Visibility(
                            visible: state.editState == EditState.layering,
                            maintainState: true,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height / 2,
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: Slider(
                                  value: state.opacityLayer,
                                  min: 0,
                                  max: 1,
                                  onChanged: context
                                      .read<EditPhotoCubit>()
                                      .changeOpacityLayer,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      MenuIconWidget(
                        onTap: () async {
                          final currentState =
                              context.read<EditPhotoCubit>().state.editState;

                          if (currentState == EditState.layering) {
                            context
                                .read<EditPhotoCubit>()
                                .changeEditState(EditState.idle);
                          } else {
                            context
                                .read<EditPhotoCubit>()
                                .changeEditState(EditState.layering);
                          }
                        },
                        icon: Icons.layers,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  MenuIconWidget(
                    onTap: () async {
                      context
                          .read<EditPhotoCubit>()
                          .changeEditState(EditState.addingText);

                      final result = await addText(context);

                      if (result == null ||
                          result is! DraggableWidgetTextChild) {
                        if (!mounted) return;
                        context
                            .read<EditPhotoCubit>()
                            .changeEditState(EditState.idle);
                        return;
                      }

                      final widget = DraggableWidget(
                        widgetId: DateTime.now().millisecondsSinceEpoch,
                        child: result,
                        onPress: (id, widget) async {
                          if (widget is DraggableWidgetTextChild) {
                            context
                                .read<EditPhotoCubit>()
                                .changeEditState(EditState.addingText);

                            final result = await addText(
                              context,
                              widget,
                            );

                            if (result == null ||
                                result is! DraggableWidgetTextChild) {
                              if (!mounted) return;
                              context
                                  .read<EditPhotoCubit>()
                                  .changeEditState(EditState.idle);
                              return;
                            }

                            if (!mounted) return;
                            context
                                .read<EditPhotoCubit>()
                                .editWidget(id, result);
                          }
                        },
                        onLongPress: (id) async {
                          final result = await showConfirmationDialog(
                            context,
                            title: "Delete Text ?",
                            desc: "Are you sure want to Delete this text ?",
                            rightText: "Delete",
                          );
                          if (result == null) return;

                          if (result) {
                            if (!mounted) return;
                            context.read<EditPhotoCubit>().deleteWidget(id);
                          }
                        },
                      );

                      if (!mounted) return;
                      context.read<EditPhotoCubit>().addWidget(widget);
                    },
                    icon: Icons.text_fields_rounded,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
