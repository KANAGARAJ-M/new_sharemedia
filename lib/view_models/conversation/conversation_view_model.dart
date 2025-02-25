import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_sharemedia/models/message.dart';
import 'package:new_sharemedia/services/chat_service.dart';

class ConversationViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ChatService chatService = ChatService();
  bool uploadingImage = false;
  final picker = ImagePicker();
  File? image;

  sendMessage(String chatId, Message message) {
    chatService.sendMessage(
      message,
      chatId,
    );
  }

  Future<String> sendFirstMessage(String recipient, Message message) async {
    String newChatId = await chatService.sendFirstMessage(
      message,
      recipient,
    );

    return newChatId;
  }

  setReadCount(String chatId, var user, int count) {
    chatService.setUserRead(chatId, user, count);
  }

  setUserTyping(String chatId, var user, bool typing) {
    chatService.setUserTyping(chatId, user, typing);
  }

  pickImage({int? source, BuildContext? context, String? chatId}) async {
    XFile? pickedFile = source == 0
        ? await picker.pickImage(
            source: ImageSource.camera,
          )
        : await picker.pickImage(
            source: ImageSource.gallery,
          );

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(
          ratioX: 1,
          ratioY: 1,
        ),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop image',
            toolbarColor: Theme.of(context!).appBarTheme.backgroundColor,
            toolbarWidgetColor: Theme.of(context).iconTheme.color,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
          ),
        ],
      );

      Navigator.of(context).pop();

      if (croppedFile != null) {
        uploadingImage = true;
        image = File(croppedFile.path);
        notifyListeners();
        showInSnackBar("Uploading image...", context);
        String imageUrl = await chatService.uploadImage(image!, chatId!);
        return imageUrl;
      }
    }
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }
}
