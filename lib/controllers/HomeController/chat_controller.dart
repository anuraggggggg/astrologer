// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, body_might_complete_normally_catch_error

import 'dart:developer';
import 'dart:io';

import 'package:astrowaypartner/models/chat_model.dart';
import 'package:astrowaypartner/services/apiHelper.dart';
import 'package:astrowaypartner/views/HomeScreen/chat/chat_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import '../../models/chat_message_model.dart';
import '../../models/message_model.dart';

class ChatController extends GetxController {
  String screen = 'chat_controller.dart';
  String? enteredMessage = '';
  APIHelper apiHelper = APIHelper();
  List<ChatModel> chatList = [];
  //customer agorachat userId
  String agorapeerUserId = "";
  //astrologer agorachat userId
  String agoraUserId = "";
  //chatId from database
  int? chatId;
  String chatusersId = "";
  String firebaseChatId = "";
  ChatMessageModel? replymessage = ChatMessageModel();

  int chatDurationis = 0;
  setchatduration(int value) {
    chatDurationis = value;
    update();
  }

  // bool chatTracker = false;

  int? userId;
  CollectionReference userChatCollectionRef =
      FirebaseFirestore.instance.collection("chats");
  CollectionReference userChatCollectionRefRTM =
      FirebaseFirestore.instance.collection("LiveChats");
  ScrollController scrollController = ScrollController();
  int fetchRecord = 5;
  int startIndex = 0;
  bool isDataLoaded = false;
  bool isAllDataLoaded = false;
  bool isMoreDataAvailable = false;
  bool isInChatScreen = false;
  updateChatScreen(bool value) {
    isInChatScreen = value;
    log('chat change isInChatScreen is $isInChatScreen');

    update();
  }

  @override
  // ignore: unnecessary_overrides
  void onInit() async {
    super.onInit();
  }

  final AudioPlayer audioPlayer = AudioPlayer();

//Get a chat list
  getChatList(bool isLazyLoading, {int? isLoading = 1}) async {
    try {
      startIndex = 0;
      if (chatList.isNotEmpty) {
        startIndex = chatList.length;
      }
      if (!isLazyLoading) {
        isDataLoaded = false;
      }
      await global.checkBody().then(
        (result) async {
          if (result) {
            isLoading == 0 ? '' : global.showOnlyLoaderDialog();
            int id = global.user.id ?? 0;
            await apiHelper
                .getchatRequest(id, startIndex, fetchRecord)
                .then((result) {
              isLoading == 0 ? '' : global.hideLoader();

              update();
              if (result.status == "200") {
                if (!isLazyLoading) {
                  chatList.clear();
                  update();
                }
                chatList.addAll(result.recordList);
                update();
                if (result.recordList.length == 0) {
                  isMoreDataAvailable = false;
                  isAllDataLoaded = true;
                }
                update();
              } else {
                global.showToast(message: "No chat list is here");
              }
            });
          }
        },
      );
      update();
    } catch (e) {
      print('Exception: $screen - getChatList():- ' + e.toString());
    }
  }

  storeChatId(int partnerId, int chatId) async {
    try {
      await global.checkBody().then(
            (result) async {
          if (result) {
            var apiResult = await apiHelper.addChatId(global.currentUserId!, partnerId, chatId);

            if (apiResult != null && apiResult.status == "200") {
              firebaseChatId = apiResult.recordList['recordList'];
              update();
              print('chat id generated: $firebaseChatId');
            } else {
              global.showToast(message: "There is some problem");
            }
          }
        },
      );
      update();
    } catch (e) {
      print('Exception: $screen - storeChatId(): ' + e.toString());
    }
  }


//Reject a chat by id
  Future rejectChatRequest(int chatId) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          global.showOnlyLoaderDialog();
          await apiHelper.chatReject(chatId).then((result) async {
            global.hideLoader();
            if (result.status == "200") {
              global.showToast(message: "Reject chat request sucessfully");
              chatList.clear();
              isAllDataLoaded = false;
              update();
              await getChatList(false);
              Get.back();
            } else {
              global.showToast(message: result.message.toString());
            }
          });
        }
      });
      update();
    } catch (e) {
      print("Exception: $screen - rejectChatRequest():" + e.toString());
    }
  }

  //accept chat request
  Future<void> acceptChatRequest(
      int chatId,
      String customerName,
      String customerProfile,
      int customerId,
      String fcmToken,
      String chatDuration,
      ) async {
    const String screen = 'ChatController → acceptChatRequest';

    log('[$screen] 🟡 Started | chatId: $chatId, customerId: $customerId');

    try {
      final isBodyValid = await global.checkBody();
      if (!isBodyValid) {
        log('[$screen] ⚠️ checkBody() failed — Aborting operation.');
        return;
      }

      global.showOnlyLoaderDialog();
      log('[$screen] 📡 Calling API → acceptChatRequest(chatId: $chatId)...');

      final apiResult = await apiHelper.acceptChatRequest(chatId);

      global.hideLoader();

      if (apiResult == null) {
        log('[$screen] ❌ API returned null');
        global.showToast(message: "❌ API response is null");
        return;
      }

      log('[$screen] ✅ API response received | status: ${apiResult.status}');

      if (apiResult.status == "200") {
        global.showToast(message: "✅ Chat request accepted");

        log('[$screen] 💾 Storing chatId for customerId: $customerId');
        await storeChatId(customerId, chatId);

        log('[$screen] 🔄 Updating chat screen flag...');
        updateChatScreen(true);

        final int duration = int.tryParse(chatDuration) ?? 0;
        log('[$screen] ⏱️ Parsed chatDuration: $duration minutes');

        log('[$screen] 🚀 Navigating to ChatScreen with:');
        log(' - flagId: 1');
        log(' - astrologerId: ${global.currentUserId}');
        log(' - customerName: $customerName');
        log(' - customerProfile: $customerProfile');
        log(' - customerId: $customerId');
        log(' - fcmToken: $fcmToken');

        Get.to(() => ChatScreen(
          flagId: 1,
          astrologerId: global.currentUserId,
          customerName: customerName,
          customerProfile: customerProfile,
          customerId: customerId,
          fcmToken: fcmToken,
          chatduration: duration,
        ));

        log('[$screen] 🧹 Clearing old chat list & refreshing...');
        chatList.clear();
        isAllDataLoaded = false;
        await getChatList(false);
      } else {
        log('[$screen] ❌ API status not 200 → ${apiResult.status}');
        global.showToast(message: "❌ Failed to accept chat request");
      }

      update();
    } catch (e, stackTrace) {
      global.hideLoader();
      log('[$screen] 🛑 Exception occurred');
      log('[$screen] ❌ Error: $e');
      log('[$screen] 📜 StackTrace: $stackTrace');
      global.showToast(message: "❌ Something went wrong while accepting chat.");
    }
  }







  bool isMe = true;
  Stream<QuerySnapshot<Map<String, dynamic>>>? getChatMessages(
      String firebaseChatId1, int? currentUserId) {
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> data = FirebaseFirestore
          .instance
          .collection('chats/$firebaseChatId1/userschat')
          .doc('$currentUserId')
          .collection('messages')
          .orderBy("createdAt", descending: true)
          .snapshots(); //orderBy("createdAt", descending: true)
      return data;
    } catch (err) {
      print("Exception - apiHelper.dart - getChatMessages()" + err.toString());
      return null;
    }
  }

  Future<void> sendReplyMessage(
      String message, int partnerId, bool isEndMessage, String replymsg) async {
    // log('chatID $chatId partnerId $partnerId');
    log('message $message replymsg $replymsg');

    try {
      if (message.trim() != '') {
        ChatMessageModel chatMessage = ChatMessageModel(
          message: message,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDelete: false,
          isRead: true,
          userId1: '${global.currentUserId}',
          userId2: '$partnerId',
          isEndMessage: isEndMessage,
          replymsg: replymsg,
        );
        update();
        await uploadMessage(firebaseChatId, '$partnerId', chatMessage);
      } else {}
    } catch (e) {
      print('Exception in sendMessage ${e.toString()}');
    }
  }

  Future<void> sendMessage(
      String message, int partnerId, bool isEndMessage) async {
    log('custoer id is $partnerId');
    // if (chatId != null) {
    try {
      if (message.trim() != '') {
        ChatMessageModel chaMessage = ChatMessageModel(
          message: message,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDelete: false,
          isRead: true,
          userId1: '${global.currentUserId}',
          userId2: '$partnerId',
          isEndMessage: isEndMessage,
          replymsg: '',
        );
        update();
        await uploadMessage(firebaseChatId, '$partnerId', chaMessage);
      } else {}
    } catch (e) {
      print('Exception in sendMessage ${e.toString()}');
    }
  }

  Future uploadMessage(
      String idUser, String partnerId, ChatMessageModel anonymous) async {
    try {
      final String globalId = global.currentUserId.toString();
      final refMessages = userChatCollectionRef //SEND BY CURRENT USER
          .doc(idUser)
          .collection('userschat')
          .doc(globalId)
          .collection('messages');
      final refMessages1 = userChatCollectionRef //SEND BY PRTNER USER
          .doc(idUser)
          .collection('userschat')
          .doc(partnerId)
          .collection('messages');
      final newMessage1 = anonymous;

      final newMessage2 = anonymous;
      newMessage2.messageId = refMessages1.id;

      var messageResult =
          await refMessages.add(newMessage1.toJson()).catchError((e) {
        print('send mess exception' + e);
      });
      newMessage1.messageId = messageResult.id;
      await userChatCollectionRef //ADD USER AND PARTNER IN THIS
          .doc(idUser)
          .collection('userschat')
          .doc(globalId)
          .collection('messages')
          .doc(newMessage1.messageId)
          .update({"messageId": newMessage1.messageId});

      newMessage2.isRead = false;
      var message1Result =
          await refMessages1.add(newMessage2.toJson()).catchError((e) {
        print('send mess exception' + e);
      });
      newMessage2.messageId = message1Result.id;
      await userChatCollectionRef
          .doc(idUser)
          .collection('userschat')
          .doc(partnerId)
          .collection('messages')
          .doc(newMessage1.messageId)
          .update({"messageId": newMessage1.messageId});
      return {
        'user1': messageResult.id,
        'user2': message1Result.id,
      };
    } catch (err) {
      print('uploadMessage err $err');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? getMessageRTMWeb(
      String channelID) {
    log('firebase  channelID $channelID');
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> data =
          userChatCollectionRefRTM
              .doc(channelID)
              .collection('messages')
              .where('isFromWeb', isEqualTo: true)
              .orderBy('createdAt')
              .snapshots();

      return data;
    } catch (err) {
      print("Exception - chatcontroller.dart - firebase" + err.toString());
      return null;
    }
  }

  Future uploadMessageRTM(
      String idUser, MessageModel anonymous, bool isdeleted) async {
    debugPrint('saving to $idUser firebase');
    log('messga sending ${anonymous.toJson()}');
    try {
      final refMessages = userChatCollectionRefRTM //SEND BY CURRENT USER
          .doc(idUser)
          .collection('messages');

      final newMessage1 = anonymous;

      final refMessages1 = userChatCollectionRefRTM //SEND BY CURRENT USER
          .doc(idUser)
          .collection('isDeleted');

      var alreadyisSnapshot = await refMessages1.get();
      if (alreadyisSnapshot.docs.isEmpty) {
        debugPrint('no field found added');
        await refMessages1.add({'isdeleted': isdeleted}).catchError((e) {
          log('creating deled field error ' + e);
        });
      } else {
        log('field isdelete already found not adding in firbase');
      }

      var messageResult =
          await refMessages.add(newMessage1.toJson()).catchError((e) {
        log('creating message in firbase exception' + e);
      });

      return {
        'user1': messageResult.id,
      };
    } catch (err) {
      log('uploadMessage err $err');
    }
  }

  Future<void> deleteBatches(String docid, bool isdeleted) async {
    final instance = FirebaseFirestore.instance;
    final batch = instance.batch();
    var collection =
        instance.collection('LiveChats').doc(docid).collection('messages');
    var snapshots = await collection.get();

    if (snapshots.docs.isNotEmpty) {
      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      var collection =
          instance.collection('LiveChats').doc(docid).collection('isDeleted');
      var updatesnapshot = await collection.get();

      if (updatesnapshot.docs.isNotEmpty) {
        // Iterate through the documents and update the isdeleted field
        for (var doc in updatesnapshot.docs) {
          await collection.doc(doc.id).update({'isdeleted': isdeleted});
        }
      } else {
        log('No documents found in the isDeleted collection.');
      }
    } else {
      log('No documents to delete in the subcollection');
    }
  }

//UPload Files to firebase
  Future<void> sendFiletoFirebase(
    // String message,
    String chatId,
    int partnerId,
    File? file,
    BuildContext context,
  ) async {
    try {
      log('sending room_chatid $chatId customerid $partnerId');
      if (file != null) {
        // global.showOnlyLoaderDialog();
        uploadImage(file, partnerId.toString(), chatId);
      } else {
        debugPrint('no file to upload on firebase');
      }
    } catch (e) {
      print('Exception in sendMessage ${e.toString()}');
    }
  }

  Future<void> uploadImage(
      File imageFile, String partnerId, String chatId) async {
    Reference storageReference = FirebaseStorage.instance.ref().child(
        '$chatId/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}');

    final uploadTask = await storageReference.putFile(imageFile);

    if (uploadTask.state == TaskState.success) {
      debugPrint('image uploaded');
    }
    String downloadURL = await storageReference.getDownloadURL();
    debugPrint('File Uploaded: $downloadURL');

    updateProfileImage(partnerId, chatId, downloadURL);
  }

  // Update Profile Image on Firebase
  Future<void> updateProfileImage(
      String partnerId, String chatId, String imageUrl) async {
    ChatMessageModel chatMessageModel = ChatMessageModel(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDelete: false,
      isRead: true,
      userId1: '${global.currentUserId}',
      userId2: partnerId,
      attachementPath: imageUrl,
      isEndMessage: false,
    );
    // Upload the message to Firestore
    await uploadMessage(chatId, partnerId, chatMessageModel);
  }
}
