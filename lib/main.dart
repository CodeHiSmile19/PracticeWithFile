import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:practice_with_file/common/app_colors.dart';
import 'package:practice_with_file/common/app_text_style.dart';
import 'package:practice_with_file/configs/app_configs.dart';
import 'package:practice_with_file/utils/os_util.dart';
import 'package:practice_with_file/widgets/app_button.dart';
import 'package:practice_with_file/widgets/select_image_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? imageSelected;
  File? fileSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              AppButton(
                title: "Chọn ảnh",
                textStyle: AppTextStyle.primaryS18W700,
                backgroundColor: AppColors.colorPrimary,
                cornerRadius: 8,
                onPressed: () {
                  showModalBottomSheet(
                    isDismissible: false,
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (BuildContext context) {
                      return SelectUploadImage(
                        takePhotoTitle: "Chụp ảnh",
                        choosePhotoTile: "Chọn từ thư viện",
                        cancelTitle: "Hủy",
                        onSubmitImage: (files) {
                          setState(() {
                            imageSelected = File(files.single.path);
                          });
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              AppButton(
                onPressed: () async {
                  await pickFile();
                },
                title: "Chọn file",
                textStyle: AppTextStyle.primaryS18W700,
                backgroundColor: AppColors.colorPrimary,
                cornerRadius: 8,
              ),
              const SizedBox(height: 20),
              if (imageSelected != null) ...[
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.file(imageSelected!),
                ),
              ],
              const SizedBox(height: 20),
              if (fileSelected != null) ...[
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    fileSelected!.path,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickFile() async {
    final checkOS = await OSUtils.checkOldAndroidVersion();

    if (checkOS) {
      PermissionStatus permissionFile = await Permission.storage.status;

      if (permissionFile != PermissionStatus.denied) {
        if (permissionFile == PermissionStatus.permanentlyDenied) {
          openAppSettings();
        } else {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: AppConfigs.listFileType,
            allowMultiple: false,
          );
          if (result != null) {
            ///handler File
            setState(() {
              fileSelected = File(result.files.single.path ?? '');
            });
          }
        }
      } else {
        final result = await Permission.storage.request();
        if (result != PermissionStatus.denied) {
          if (result == PermissionStatus.permanentlyDenied) {
            if (context.mounted) {
              Navigator.pop(context);
            }
            openAppSettings();
          } else {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: AppConfigs.listFileType,
              allowMultiple: false,
            );
            if (result != null) {
              setState(() {
                fileSelected = File(result.files.single.path ?? '');
              });
            }
          }
        }
        permissionFile = await Permission.storage.status;
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConfigs.listFileType,
        allowMultiple: false,
      );
      if (result != null) {
        setState(() {
          fileSelected = File(result.files.single.path ?? '');
        });
      }
    }
  }
}
