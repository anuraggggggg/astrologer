// ignore_for_file: must_be_immutable, avoid_print, use_build_context_synchronously, deprecated_member_use

import 'dart:developer';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:astrowaypartner/views/HomeScreen/chat/zoomimagewidget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import '../../../constants/colorConst.dart';
import '../../../controllers/HomeController/call_controller.dart';
import '../../../controllers/HomeController/chat_controller.dart';
import '../../../controllers/HomeController/timer_controller.dart';
import '../../../controllers/HomeController/wallet_controller.dart';
import '../../../models/History/chat_history_model.dart';
import '../../../models/chat_message_model.dart';
import '../../../services/apiHelper.dart';
import '../../../widgets/chat_app_bar_widget.dart';
import 'pdfviewerpage.dart';

class ChatScreen extends StatefulWidget {
  int flagId;
  final String customerName;
  final int customerId;
  final String? fireBasechatId;
  final String? chatId;
  int? astrologerId;
  final String? astrologerName;
  final String customerProfile;
  final String? fcmToken;
  final int? chatduration;

  ChatHistoryModel? chatHistoryData;
  ChatScreen({
    super.key,
    required this.flagId,
    required this.customerName,
    required this.customerProfile,
    required this.customerId,
    required this.chatduration,
    this.fireBasechatId,
    this.chatId,
    this.astrologerId,
    this.astrologerName,
    this.chatHistoryData,
    this.fcmToken,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final chatController = Get.find<ChatController>();
  final callController = Get.find<CallController>();
  final timecontroller = Get.find<TimerController>();
  final apiHelper = APIHelper();
  final messageController = TextEditingController();
  final sendtextfocusnode = FocusNode();
  final walletController = Get.put(WalletController());

  @override
  void initState() {
    apiHelper.setAstrologerOnOffBusyline("Busy");
    log('getting flagid ${widget.flagId}');
    log('init newIsStartTimer ${callController.newIsStartTimer}');
    log('Customer ID is ${widget.customerId}');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    apiHelper.setAstrologerOnOffBusyline("Online");
    log('chat screen ondispose online ');
    callController.newIsStartTimer = false;
    callController.update();
    // chatController.chatTracker = false;
    // chatController.update();
  }

  @override
  Widget build(BuildContext context) {
    log('time intial timecontroller is ${callController.newIsStartTimer}');
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        debugPrint("didPop: $didPop");
        if (!didPop) {
          backpress();
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: ChatAppBar(
            counterduration: widget.chatduration,
            profile: widget.customerProfile,
            customername: widget.customerName,
            height: 80,
            backgroundColor: COLORS().primaryColor,
            leading: InkWell(
              onTap: () async {
                backpress();
              },
              child: GestureDetector(
                onTap: () => backpress(),
                child: Icon(
                  Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                ),
              ),
            ),
            actions: [
              widget.flagId == 2
                  ? const SizedBox()
                  : GetBuilder<CallController>(builder: (cc) {
                      return cc.newIsStartTimer
                          ? const SizedBox()
                          : const SizedBox();
                    }),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/chat_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                GetBuilder<ChatController>(builder: (chatController) {
                  return Column(
                    children: [
                      Expanded(
                        child:
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                stream: chatController.getChatMessages(
                                    widget.fireBasechatId == null
                                        ? chatController.firebaseChatId
                                        : widget.fireBasechatId!,
                                    global.currentUserId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState.name ==
                                      "waiting") {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else {
                                    if (snapshot.hasError) {
                                      return Text(
                                          'snapShotError :- ${snapshot.error}');
                                    } else {
                                      List<ChatMessageModel> messageList = [];
                                      for (var res in snapshot.data!.docs) {
                                        messageList.add(
                                            ChatMessageModel.fromJson(
                                                res.data()));
                                      }
                                      // Play sound when a new message is received
                                      if (messageList.isNotEmpty &&
                                          snapshot.hasData) {
                                        debugPrint(
                                            'first msage is ${messageList.first.message} ');

                                        if (messageList.first.isEndMessage ==
                                            true) {
                                        } else {
                                          // Ensure this only plays on new messages
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            chatController.audioPlayer.play(
                                                AssetSource(
                                                    'sounds/message_sound.mp3'));
                                          });
                                        }
                                      }
                                      print(messageList.length);
                                      return ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          padding:
                                              EdgeInsets.only(bottom: 10.h),
                                          itemCount: messageList.length,
                                          shrinkWrap: true,
                                          reverse: true,
                                          itemBuilder: (context, index) {
                                            ChatMessageModel message =
                                                messageList[index];
                                            chatController.isMe =
                                                message.userId1 ==
                                                    '${global.currentUserId}';
                                            return messageList[index]
                                                        .isEndMessage ==
                                                    true
                                                ? Container(
                                                    color: const Color.fromARGB(
                                                        255, 247, 244, 211),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      messageList[index]
                                                          .message!,
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        chatController.isMe
                                                            ? MainAxisAlignment
                                                                .end
                                                            : MainAxisAlignment
                                                                .start,
                                                    crossAxisAlignment:
                                                        chatController.isMe
                                                            ? CrossAxisAlignment
                                                                .end
                                                            : CrossAxisAlignment
                                                                .start,
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: chatController
                                                                  .isMe
                                                              ? messageList[index]
                                                                          .attachementPath ==
                                                                      ""
                                                                  ? const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      247,
                                                                      244,
                                                                      211)
                                                                  : Colors.white
                                                              : messageList[index]
                                                                          .attachementPath ==
                                                                      ""
                                                                  ? Colors.grey
                                                                      .shade100
                                                                  : Colors
                                                                      .white,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                const Radius
                                                                    .circular(
                                                                    12),
                                                            topRight:
                                                                const Radius
                                                                    .circular(
                                                                    12),
                                                            bottomLeft: chatController
                                                                    .isMe
                                                                ? const Radius
                                                                    .circular(0)
                                                                : const Radius
                                                                    .circular(
                                                                    12),
                                                            bottomRight: chatController
                                                                    .isMe
                                                                ? const Radius
                                                                    .circular(0)
                                                                : const Radius
                                                                    .circular(
                                                                    12),
                                                          ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10,
                                                                horizontal: 16),
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 16,
                                                            horizontal: 8),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              chatController
                                                                      .isMe
                                                                  ? CrossAxisAlignment
                                                                      .start
                                                                  : CrossAxisAlignment
                                                                      .start,
                                                          children: [
                                                            GetBuilder<
                                                                ChatController>(
                                                              builder:
                                                                  (ccontroller) =>
                                                                      SwipeTo(
                                                                key:
                                                                    UniqueKey(),
                                                                iconOnLeftSwipe:
                                                                    Icons
                                                                        .arrow_forward,
                                                                iconOnRightSwipe:
                                                                    Icons.reply,
                                                                onRightSwipe:
                                                                    (details) {
                                                                  dev.log(
                                                                      "\n Left Swipe Data --> $details");
                                                                  sendtextfocusnode
                                                                      .requestFocus();
                                                                  ccontroller
                                                                          .replymessage =
                                                                      messageList[
                                                                          index];
                                                                  ccontroller
                                                                      .update();
                                                                  dev.log(
                                                                      " Swipe details --> ${ccontroller.replymessage!.toJson()}");
                                                                },
                                                                swipeSensitivity:
                                                                    5,
                                                                child: messageList[index].replymsg !=
                                                                            null &&
                                                                        messageList[index].replymsg !=
                                                                            ""
                                                                    ? Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          IntrinsicHeight(
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Container(
                                                                                  color: Colors.green,
                                                                                  width: 1.w,
                                                                                ),
                                                                                SizedBox(width: 3.w),
                                                                                messageList[index].replymsg != null && messageList[index].replymsg!.contains('.png') || messageList[index].replymsg != null && messageList[index].replymsg!.contains('.jpg') || messageList[index].replymsg != null && messageList[index].replymsg!.contains('.jpeg')
                                                                                    ? Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          CachedNetworkImage(
                                                                                            height: 10.h,
                                                                                            width: 30.w,
                                                                                            imageUrl: messageList[index].replymsg!,
                                                                                            imageBuilder: (context, imageProvider) => Image.network(
                                                                                              messageList[index].replymsg!,
                                                                                              width: MediaQuery.of(context).size.width,
                                                                                              fit: BoxFit.fill,
                                                                                            ),
                                                                                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                                            errorWidget: (context, url, error) => Image.asset(
                                                                                              'assets/images/close.png',
                                                                                              height: 10.h,
                                                                                              width: 30.w,
                                                                                              fit: BoxFit.fill,
                                                                                            ),
                                                                                          ),
                                                                                          Text(DateFormat().add_jm().format(messageList[index].createdAt!),
                                                                                              style: const TextStyle(
                                                                                                color: Colors.grey,
                                                                                                fontSize: 9.5,
                                                                                              )),
                                                                                        ],
                                                                                      )
                                                                                    : messageList[index].replymsg!.contains('.pdf')
                                                                                        ? SizedBox(
                                                                                            height: 9.h,
                                                                                            width: 9.h,
                                                                                            child: const Image(image: AssetImage('assets/images/pdf.png')),
                                                                                          )
                                                                                        : messageList[index].replymsg != "" || messageList[index].replymsg != null
                                                                                            ? SizedBox(
                                                                                                width: 70.w,
                                                                                                child: Text(
                                                                                                  '${messageList[index].replymsg}',
                                                                                                  style: TextStyle(
                                                                                                    color: Colors.grey,
                                                                                                    fontSize: 12.sp,
                                                                                                  ),
                                                                                                ))
                                                                                            : SizedBox(
                                                                                                width: 70.w,
                                                                                                child: Text(
                                                                                                  '${messageList[index].message}',
                                                                                                  style: TextStyle(
                                                                                                    color: Colors.grey,
                                                                                                    fontSize: 12.sp,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                70.w,
                                                                            child:
                                                                                Text(
                                                                              '${messageList[index].message}',
                                                                              style: TextStyle(color: Colors.black, fontSize: 12.sp),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : messageList[index].attachementPath !=
                                                                            ""
                                                                        ? messageList[index].attachementPath!.toLowerCase().contains('.pdf')
                                                                            ? InkWell(
                                                                                onTap: () {
                                                                                  debugPrint('pdf onclicked');
                                                                                  Get.to(() => PdfViewerPage(url: messageList[index].attachementPath!));
                                                                                },
                                                                                child: SizedBox(
                                                                                  height: 9.h,
                                                                                  width: 9.h,
                                                                                  child: const Image(image: AssetImage('assets/images/pdf.png')),
                                                                                ),
                                                                              )
                                                                            : messageList[index].attachementPath!.toLowerCase().contains('.png') || messageList[index].attachementPath!.toLowerCase().contains('.jpg') || messageList[index].attachementPath!.toLowerCase().contains('.jpeg')
                                                                                ? InkWell(
                                                                                    onTap: () {
                                                                                      Get.to(() => zoomImageWidget(url: messageList[index].attachementPath!));
                                                                                    },
                                                                                    child: Column(
                                                                                      children: [
                                                                                        CachedNetworkImage(
                                                                                          height: 10.h,
                                                                                          width: 30.w,
                                                                                          imageUrl: messageList[index].attachementPath!,
                                                                                          imageBuilder: (context, imageProvider) => Image.network(
                                                                                            messageList[index].attachementPath!,
                                                                                            width: MediaQuery.of(context).size.width,
                                                                                            fit: BoxFit.fill,
                                                                                          ),
                                                                                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                                          errorWidget: (context, url, error) => Image.asset(
                                                                                            'assets/images/close.png',
                                                                                            height: 10.h,
                                                                                            width: 30.w,
                                                                                            fit: BoxFit.fill,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                : const SizedBox(
                                                                                    child: Icon(Icons.not_interested_outlined),
                                                                                  )
                                                                        : Container(
                                                                            constraints:
                                                                                BoxConstraints(maxWidth: Get.width - 100),
                                                                            child:
                                                                                Text(
                                                                              messageList[index].message!,
                                                                              style: TextStyle(
                                                                                color: chatController.isMe ? Colors.black : Colors.black,
                                                                              ),
                                                                              textAlign: chatController.isMe ? TextAlign.start : TextAlign.start,
                                                                            ),
                                                                          ),
                                                              ),
                                                            ),
                                                            messageList[index]
                                                                        .createdAt !=
                                                                    null
                                                                ? Container(
                                                                    //! HERE
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            8.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                            DateFormat().add_jm().format(messageList[index]
                                                                                .createdAt!),
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.grey,
                                                                              fontSize: 9.5,
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  )
                                                                : const SizedBox()
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                          });
                                    }
                                  }
                                }),
                      ),
                    ],
                  );
                }),

                //SEND MSG
                widget.flagId == 2
                    ? const SizedBox()
                    : GetBuilder<ChatController>(
                        builder: (ccontroller) => Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (ccontroller.replymessage?.message?.isNotEmpty ==
                                        true ||
                                    ccontroller.replymessage?.attachementPath
                                            ?.isNotEmpty ==
                                        true)
                                ? _replywidget()
                                : const SizedBox.shrink(),
                            Container(
                              padding: EdgeInsets.only(left: 2.w),
                              margin: EdgeInsets.only(bottom: 1.h),
                              child: GetBuilder<ChatController>(
                                  builder: (chatController) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(2.w),
                                              bottomRight: Radius.circular(2.w),
                                            )),
                                        height: 7.h,
                                        child: TextFormField(
                                          focusNode: sendtextfocusnode,
                                          controller: messageController,
                                          onChanged: (value) {},
                                          cursorColor: Colors.black,
                                          style: const TextStyle(
                                              color: Colors.black),
                                          decoration: InputDecoration(
                                            hintText: 'Enter message here',
                                            hintStyle: TextStyle(
                                                color: Colors.grey.shade600),
                                            contentPadding:
                                                EdgeInsets.only(left: 2.w),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(2.w),
                                                bottomRight:
                                                    Radius.circular(2.w),
                                              ),
                                              borderSide: const BorderSide(
                                                  color: Colors.grey),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(2.w),
                                                  bottomRight:
                                                      Radius.circular(2.w)),
                                              borderSide: const BorderSide(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(bottom: 1.h),
                                      padding: const EdgeInsets.only(left: 3.0),
                                      child: Material(
                                        elevation: 3,
                                        color: Colors.transparent,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(100),
                                        ),
                                        child: Container(
                                            height: 6.h,
                                            width: 6.h,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade700,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            child: InkWell(
                                              onTap: () async {
                                                //! Attachement work
                                                String? filepicked =
                                                    await pickFiles();
                                                log('onclick file is $filepicked');
                                                chatController
                                                    .sendFiletoFirebase(
                                                  widget.fireBasechatId == null
                                                      ? chatController
                                                          .firebaseChatId
                                                      : widget.fireBasechatId!,
                                                  widget.customerId,
                                                  File(filepicked!),
                                                  context,
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5.0),
                                                child: Icon(
                                                  Icons.file_copy_sharp,
                                                  size: 18.sp,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(bottom: 1.h),
                                      padding: const EdgeInsets.only(left: 1.0),
                                      child: Material(
                                        elevation: 3,
                                        color: Colors.transparent,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(100),
                                        ),
                                        child: Container(
                                          height: 6.h,
                                          width: 6.h,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade700,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              //SEND TO SERVER MSG
                                              if (ccontroller.replymessage!
                                                          .message !=
                                                      null ||
                                                  ccontroller.replymessage!
                                                          .attachementPath !=
                                                      "") {
                                                dev.log(
                                                    'user replyying msg is ${ccontroller.replymessage!.message}');
                                                chatController.sendReplyMessage(
                                                  messageController
                                                      .text, //what we are replying
                                                  widget.customerId,
                                                  false,
                                                  ccontroller.replymessage
                                                              ?.attachementPath !=
                                                          ""
                                                      ? ccontroller
                                                              .replymessage!
                                                              .attachementPath ??
                                                          ''
                                                      : ccontroller.replymessage
                                                              ?.message ??
                                                          'N/A',
                                                );

                                                messageController.clear();
                                              } else {
                                                if (messageController.text !=
                                                    "") {
                                                  chatController.sendMessage(
                                                      messageController.text,
                                                      widget.customerId,
                                                      false);
                                                  messageController.clear();
                                                }
                                              }
                                              //clear reply field too
                                              ccontroller.replymessage!.reset();
                                              ccontroller.update();
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5.0),
                                              child: Icon(
                                                Icons.send,
                                                size: 18.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ],
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> pickFiles() async {
    // Define the allowed file extensions
    List<String> allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

    // Prompt the user to pick files
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    try {
      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        log('file is ${files[0].path}');
        return files[0].path;
      } else {
        log('selecting file error');
        return '';
      }
    } on Exception catch (e) {
      log('file error $e');
      return '';
    }
  }

  Widget _replywidget() {
    return Container(
      width: 73.w, //87.w
      height: 30.h,
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2.w),
            topRight: Radius.circular(2.w),
          )),
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      child: SingleChildScrollView(
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.green,
                    width: 1.w,
                  ),
                  SizedBox(width: 1.w),
                  GetBuilder<ChatController>(
                    builder: (controller) => Stack(
                      children: [
                        Container(
                            width: 67.w,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(2.w),
                                topRight: Radius.circular(2.w),
                              ),
                            ),
                            //CHECKC WHAT IS YOU SWIPING
                            child: controller.replymessage!.message != "" &&
                                    controller.replymessage!.message != null
                                ? Text(
                                    '${controller.replymessage!.message}',
                                    style: TextStyle(
                                        fontSize: 12.sp, color: Colors.black),
                                  )
                                : controller.replymessage?.attachementPath != null &&
                                        controller.replymessage!.attachementPath!
                                            .contains('pdf')
                                    ? SizedBox(
                                        height: 9.h,
                                        width: 9.h,
                                        child: const Image(
                                            image: AssetImage(
                                                'assets/images/pdf.png')),
                                      )
                                    : controller.replymessage?.attachementPath != null &&
                                                controller.replymessage!
                                                    .attachementPath!
                                                    .toLowerCase()
                                                    .contains('.png') ||
                                            controller.replymessage?.attachementPath !=
                                                    null &&
                                                controller.replymessage!
                                                    .attachementPath!
                                                    .toLowerCase()
                                                    .contains('.jpg') ||
                                            controller.replymessage?.attachementPath !=
                                                    null &&
                                                controller.replymessage!
                                                    .attachementPath!
                                                    .toLowerCase()
                                                    .contains('.jpeg')
                                        ? CachedNetworkImage(
                                            height: 10.h,
                                            width: 30.w,
                                            imageUrl: controller
                                                .replymessage!.attachementPath!,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Image.network(
                                              controller.replymessage!
                                                  .attachementPath!,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              fit: BoxFit.fill,
                                            ),
                                            placeholder: (context, url) =>
                                                const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              'assets/images/close.png',
                                              height: 10.h,
                                              width: 30.w,
                                              fit: BoxFit.fill,
                                            ),
                                          )
                                        : const SizedBox.shrink()),
                        Positioned(
                          top: 1,
                          right: 1,
                          child: GestureDetector(
                            onTap: () {
                              controller.replymessage!.reset();
                              controller.update();
                            },
                            child: const Icon(Icons.close),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void backpress() async {
    debugPrint('inside it appbar click');
    callController.newIsStartTimer = false;
    callController.update();
    await walletController.getAmountList();

    if (widget.flagId == 1) {
      chatController.sendMessage(
          '${global.user.name} -> ended chat', widget.customerId, true);
      global.sendNotification(
          fcmToken: widget.fcmToken, title: 'End chat from astrologer');
      bool success = await apiHelper.setAstrologerOnOffBusyline("Online");
      if (success) {
        log('Astrologer status set to Online successfully');
        Get.back();
      } else {
        log('Failed to set Astrologer status to Online');
      }
      final timerController = Get.find<TimerController>();
      timerController.min = 0;
      timerController.minText = "";
      timerController.sec = 0;
      timerController.secText = "";
      timerController.timer!.cancel();
      timerController.secTimer!.cancel();
      timerController.update();
    }
    chatController.isInChatScreen = false;
    chatController.update();
  }
}
