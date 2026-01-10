import 'dart:async';
import 'dart:convert';

// import 'package:emoji_picker/emoji_picker.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_socket_io/flutter_socket_io.dart';
// import 'package:flutter_socket_io/socket_io_business.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:kadingira/flat_widgets/flat_action_btn.dart';
// import 'package:kadingira/flat_widgets/flat_message_input_box.dart';
import 'package:http/http.dart' as http;
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
// import 'package:kadingira/main.dart';
// import 'package:kadingira/models/ChatModel.dart';
// import 'package:kadingira/models/MessageModel.dart';
// import 'package:kadingira/models/chat.dart';
// import 'package:kadingira/models/chat_message.dart';
// import 'package:kadingira/models/user.dart';
// import 'package:kadingira/provider/chat_provider.dart';
// import 'package:kadingira/provider/notification_provider.dart';
// import 'package:kadingira/provider/socket_provider.dart';
// import 'package:kadingira/screens/messages_screen.dart';
// import 'package:kadingira/utils/colors.dart';
// import 'package:kadingira/utils/utils.dart';
// import 'package:kadingira/widgets/OwnMessageCard.dart';
// import 'package:kadingira/widgets/ReplyCard.dart';
// import 'package:kadingira/widgets/custom_dialog.dart';
// import 'package:material_dialogs/material_dialogs.dart';
// import 'package:material_dialogs/widgets/buttons/icon_button.dart';
// import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:nurebo/models/chat_message.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/custom_dialog.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
// import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';


class ChatScreen extends StatefulWidget {
  final String? aId;
  final String? bId;
  final User? user;
  final String? receiverProfileImage;
  final String? receiverUsername;
  final String? receiverId;
  final String? chatId;
  final List<ChatMessage>? messages;

  const ChatScreen({super.key, this.aId, this.bId, this.user, this.receiverProfileImage, this.receiverUsername, this.receiverId, this.chatId, this.messages/*, this.recipient, this.title*/});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // List dbMessages = [];
  late IO.Socket? socket;
  // FocusNode focusNode = FocusNode();
  // List<ChatMessage> socketMessages = [];
  var chat;
  bool _isTyping = false;
  Timer? _typingTimer;
  // String testoRicevuto = "";
  // bool connesso = false;

  final TextEditingController _textController = TextEditingController();
  final TextEditingController _editChatTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late SocketProvider socketProvider;

  bool isActiveEditableAppbar = false;
  ChatMessage? selectedChatMessage = null;
  String newChatMessageText = '';
  List<ChatMessage> chatMessages = [];
  int? chatMessagesLength;
  // var timer;
  int chatMessageLoadedIndex = 0;

  int currentLength = 0;
  final int increment = 10;
  bool isLoading = false;


  Future editChatMessage(String? oldText, String? senderId, String? receiverId, DateTime? sentAt, String newText) async {
    // socketProvider = Provider.of<SocketProvider>(context, listen: true);

    var url = Uri.parse(Utils.httpServerUrl + "chat_message/edit/text");

    Map/*<String, String>*/ body = {
      "old_text": oldText,
      "new_text": newText,
      "sender_id": senderId,
      "receiver_id": receiverId,
      "sent_at": sentAt.toString(),
    };

    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    //print("response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      socketProvider.editChatMessageInClient(
        oldText,
        senderId,
        receiverId,
        sentAt,
        newText
      );

      socket!.emit(
          "send_edit_chat_message",
          {
            "oldText": oldText,
            "newText": newText,
            "senderId": senderId,
            "receiverId": receiverId,
            "chatId": socketProvider.chatId,
            "sentAt": sentAt.toString(),
          }
      );

      return jsonData;
    }
  }

  Future deleteChatMessage(String? text, String? senderId, String? receiverId, DateTime? sentAt) async {
    // socketProvider = Provider.of<SocketProvider>(context, listen: true);
    var url = Uri.parse(Utils.httpServerUrl + "chat_message/delete/both");

    Map/*<String, String>*/ body = {
      "text": text,
      "sender_id": senderId,
      "receiver_id": receiverId,
      "sent_at": sentAt.toString(),
    };

    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    //print("response.statusCode:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // for(var e in socketProvider.messageList){
      //   if(e.chat_id.toString() == widget.chatId.toString()){
      //     for(var e1 in e.chat_message_list){
      //       if(e1.sender_id == senderId && e1.receiver_id == receiverId
      //           /*&& e1.sent_at == sentAt*/ && e1.text == text){
      //         await e.chat_message_list.remove(e1);
      //         break;
      //       }
      //     }
      //   }
      // }
      socketProvider.deleteChatMessageInClient(
          text,
          senderId,
          receiverId,
          sentAt
      );

      socket!.emit(
          "send_remove_chat_message",
          {
            "text": text,
            "senderId": senderId,
            "receiverId": receiverId,
            "chatId": socketProvider.chatId,
            "sentAt": sentAt.toString(),
          }
      );

      return jsonData;
    }
  }

  Future getChatIDs() async {
    // var url = Uri.parse(Constants.serverUrl + "chat/users");
    //
    // Map/*<String, String>*/ body = {
    //   "a_id": aId,
    //   "b_id": bId,
    // };
    //
    // var response = await http.post(
    //     url,
    //     body: jsonEncode(body),
    //     headers: {
    //       'Accept': '*/*',
    //       'Content-Type': 'application/json',
    //       'Accept-encoding': 'gzip, deflate',
    //       'connection': 'keep-alive',
    //     }
    // );
    //
    // //print("response.statusCode:");
    // //print(response.statusCode);
    // if(response.statusCode >= 200 && response.statusCode < 400) {
    //   var jsonData = json.decode(response.body);
    //   setState(() {
    //     chat = jsonData;
    //     chatId = chat[0]['id'];
    //   });
    //
    //   return jsonData;
    // }
  }

  Future updateLastOpeningChat() async {
    var url;
    // //print('allloooo');
    // //print(chatId);
    // //print(widget.user.id);
    // //print(widget.aId);
    // //print(widget.bId);
    // if(widget.user.id == aId){
    if(widget.user!.id == widget.aId){
      url = Uri.parse(Utils.httpServerUrl + "chat/update_user_a_last_opening");
    }
    else if(widget.user!.id == widget.bId){
      url = Uri.parse(Utils.httpServerUrl + "chat/update_user_b_last_opening");
    }
    else{
      //print('nessun last opening chat aggiornata');
      return null;
    }
    // var url = Uri.parse(Constants.serverUrl + "chat_message/user");

    // Map/*<String, String>*/ body = {
    //   "user_a_id": aId,
    //   "user_b_id": bId,
    //   "chat_id": chatId.toString(),
    //   "time": DateTime.now().toString(),
    // };

    DateTime lastOpeningAt = DateTime.now();

    Map/*<String, String>*/ body = {
      "user_a_id": widget.aId,
      "user_b_id": widget.bId,
      "chat_id": widget.chatId.toString(),
      "time": lastOpeningAt.toString(),
    };

    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   dbMessages = jsonData;
      // });
      //print('last opening chat aggiornata a ');
      //print(jsonData);


      // int c = 0;
      for(var e in socketProvider.messageList){
        if(e.chat_id.toString() == widget.chatId.toString()){
          if(e.user_a_id == widget.user!.id){
            e.user_a_last_opening_at = lastOpeningAt;
            // for(int j = e.chat_message_list.length - 1; j > 0; j--){
            //   if(e.chat_message_list[j].sent_at
            //       .isBefore(e.user_b_last_opening_at)){
            //     e.unread_messages = c;
            //     break;
            //   }
            //   c++;
            // }
            socketProvider.updateOpeningChat(
                widget.chatId.toString(),
                true,
                lastOpeningAt
            );

            socket!.emit(
                "send_opening_chat",
                {
                  "userId": widget.user!.id.toString(),
                  "isUserA": 'true',
                  "chatId": widget.chatId.toString(),
                  "lastOpeningAt": lastOpeningAt.toString(),
                }
            );

            e.unread_messages = 0;
          }
          else if(e.user_b_id == widget.user!.id){
            e.user_b_last_opening_at = lastOpeningAt;
            // for(int j = e.chat_message_list.length - 1; j > 0; j--){
            //   if(e.chat_message_list[j].sent_at
            //       .isBefore(e.user_a_last_opening_at)){
            //     e.unread_messages = c;
            //     break;
            //   }
            //   c++;
            // }
            socketProvider.updateOpeningChat(
                widget.chatId.toString(),
                false,
                lastOpeningAt
            );

            socket!.emit(
                "send_opening_chat",
                {
                  "userId": widget.user!.id.toString(),
                  "isUserA": 'false',
                  "chatId": widget.chatId.toString(),
                  "lastOpeningAt": lastOpeningAt.toString(),
                }
            );

            e.unread_messages = 0;
          }
        }
      }

      // //print('c656565');
      // //print(c);

      return jsonData;
    }
  }

  Future updateLastClosingChat() async {
    var url;
    // //print('allloooo');
    // //print(chatId);
    // //print(widget.user.id);
    // //print(widget.aId);
    // //print(widget.bId);
    // if(widget.user.id == aId){
    if(widget.user!.id == widget.aId){
      url = Uri.parse(Utils.httpServerUrl + "chat/update_user_a_last_closing");
    }
    else if(widget.user!.id == widget.bId){
      url = Uri.parse(Utils.httpServerUrl + "chat/update_user_b_last_closing");
    }
    else{
      //print('nessun last closing chat aggiornata');
      return null;
    }
    // var url = Uri.parse(Constants.serverUrl + "chat_message/user");

    // Map/*<String, String>*/ body = {
    //   "user_a_id": aId,
    //   "user_b_id": bId,
    //   "chat_id": chatId.toString(),
    //   "time": DateTime.now().toString(),
    // };

    DateTime lastClosingAt = DateTime.now();

    Map/*<String, String>*/ body = {
      "user_a_id": widget.aId,
      "user_b_id": widget.bId,
      "chat_id": widget.chatId.toString(),
      "time": lastClosingAt.toString(),
    };

    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    // //print('vavolooo8888');
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   dbMessages = jsonData;
      // });
      //print('last closing chat aggiornata a ');
      //print(jsonData);

      // int c = 0;
      for(var e in socketProvider.messageList){
        if(e.chat_id.toString() == widget.chatId.toString()){
          if(e.user_a_id == widget.user!.id){
            e.user_a_last_closing_at = lastClosingAt;

            socketProvider.updateClosingChat(
                widget.chatId.toString(),
                true,
                lastClosingAt
            );

            socket!.emit(
                "send_closing_chat",
                {
                  "userId": widget.user!.id.toString(),
                  "isUserA": 'true',
                  "chatId": widget.chatId.toString(),
                  "lastClosingAt": lastClosingAt.toString(),
                }
            );
            // for(int j = e.chat_message_list.length - 1; j > 0; j--){
            //   if(e.chat_message_list[j].sent_at
            //       .isBefore(e.user_b_last_opening_at)){
            //     e.unread_messages = c;
            //     break;
            //   }
            //   c++;
            // }

            // setState(() {
              e.unread_messages = 0;
            // });
            // //print('vavolooo');
          }
          else if(e.user_b_id == widget.user!.id){
            e.user_b_last_closing_at = lastClosingAt;

            socketProvider.updateClosingChat(
                widget.chatId.toString(),
                false,
                lastClosingAt
            );

            socket!.emit(
                "send_closing_chat",
                {
                  "userId": widget.user!.id.toString(),
                  "isUserA": 'false',
                  "chatId": widget.chatId.toString(),
                  "lastClosingAt": lastClosingAt.toString(),
                }
            );

            // for(int j = e.chat_message_list.length - 1; j > 0; j--){
            //   if(e.chat_message_list[j].sent_at
            //       .isBefore(e.user_a_last_opening_at)){
            //     e.unread_messages = c;
            //     break;
            //   }
            //   c++;
            // }

            // setState(() {
              e.unread_messages = 0;
            // });
            // //print('vavolooo');

          }
        }
      }

      // //print('c656565');
      // //print(c);

      return jsonData;
    }
  }

  // Future getAllUserChatMessage() async {
  //   var url = Uri.parse(Constants.serverUrl + "chat_message/user");
  //
  //   Map/*<String, String>*/ body = {
  //     "a_id": widget.aId,
  //     "b_id": widget.bId,
  //   };
  //   // Map/*<String, String>*/ body = {
  //   //   "a_id": aId,
  //   //   "b_id": bId,
  //   // };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     setState(() {
  //       dbMessages = jsonData;
  //     });
  //
  //     return jsonData;
  //   }
  // }

  // Future getChat(/*String aId, String bId*/) async {
  //   // //print("aId00:" + widget.aId.toString());
  //   // //print("bId00:" + widget.bId.toString());
  //
  //   var url = Uri.parse(Constants.serverUrl + "chat/users");
  //
  //   // Map/*<String, String>*/ body = {
  //   //   "a_id": aId,
  //   //   "b_id": bId,
  //   // };
  //   Map/*<String, String>*/ body = {
  //     "a_id": widget.aId,
  //     "b_id": widget.bId,
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   //print("response.statusCode ccccc2:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     setState(() {
  //       chat = jsonData;
  //       // chatId = chat[0]['id'];
  //       // user_a_last_opening_at = DateTime.parse(chat[0]['user_a_last_opening_at']);
  //       // user_b_last_opening_at = DateTime.parse(chat[0]['user_b_last_opening_at']);
  //     });
  //
  //     return jsonData;
  //   }
  // }

  insertChatMessage(String message, String? senderId, String? receiverId, String chatId, DateTime sentAt, User user) async {
    // var socketProvider = Provider.of<SocketProvider>(context, listen: false);

    var url = Uri.parse(Utils.httpServerUrl + "chat_message/insert");

    Map/*<String, String>*/ body = {
      "chat_id": chatId,
      "sender_id": senderId,
      "sender_name": user.name,
      "sender_profile_image": user.profile_image,
      "receiver_id": receiverId,
      "text": message,
      "sent_at": sentAt.toString(),
    };

    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );

    //print('rex t');
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // //print('jsonData insert');
      // //print(jsonData);
      // socketProvider.addMessage(
      //   new ChatMessage(
      //     text: message,
      //     chatId: chatId,
      //     sender_id: senderId,
      //     receiver_id: receiverId,
      //     send_at: DateTime.now()
      //   )
      // );
      // //print('e.text');
      // for(var e in socketProvider.messages){
      //   //print(e.text);
      // }

      // sendMessage(
      //   message: message,
      //   // widget.sourceChat?.id,
      //   senderId: senderId,
      //   // widget.chatModel.id,
      //   // receiverId: widget.user.id.toString() != aId.toString()
      //   //   ? aId
      //   //   : bId,
      //   receiverId: receiverId,
      //   senderProfileImage: widget.user.profile_image,
      //   senderUsername: widget.user.username,
      // );

      /*socketProvider.addChatMessage(
          ChatMessage(
            text: message,
            receiver_id: receiverId,
            sender_id: senderId,
            // chatId: chatId.toString(),
            chat_id: widget.chatId.toString(),
            sent_at: sentAt,
            type: 'source',
            is_visible_for_sender: 1,
            is_visible_for_receiver: 1,

            // send_at: DateTime.now(),
            // send_at:
          )
      );

      for(var e in socketProvider.messageList){
        // if(e.chat_id.toString() == chatId.toString()){
        if(e.chat_id.toString() == widget.chatId.toString()){
          // socketProvider.messageList.remove(e);
          // socketProvider.messageList.add(
          //     new Chat(
          //       // chat_id: chatId,
          //       chat_id: int.tryParse(widget.chatId),
          //       receiver_id: receiverId,
          //       sender_id: widget.user.id,
          //       receiver_username: widget.receiverUsername,
          //       sender_username: widget.user.username,
          //       sent_at: DateTime.now().toLocal(),
          //       text: message,
          //       receiver_profile_image: widget.receiverProfileImage,
          //       sender_profile_image: widget.user.profile_image,
          //       user_a_id: widget.aId,
          //       user_b_id: widget.bId,
          //       // user_a_last_opening_at: user_a_last_opening_at,
          //       // user_b_last_opening_at: user_b_last_opening_at,
          //     )
          // );

          e.chat_message_list.add(
              ChatMessage(
                // id: msg['chatId'],
                text: message,
                receiver_id: receiverId,
                chat_id: widget.chatId,
                sender_id: widget.user.id,
                sent_at: sentAt.toLocal(),
                type: 'source',
                is_visible_for_sender: 1,
                is_visible_for_receiver: 1,
              )
          );
          // e.unread_messages++;

          // //print('tttttt');
          for(var e in socketProvider.messageList){
            e.chat_message_list.sort((a, b) {
              // return a.sent_at.compareTo(b.sent_at);
              return a.sent_at.compareTo(b.sent_at);
            });
            // //print(e.chat_message_list.last.text);
            // //print(e.chat_message_list.last.sent_at.toString());
          }
          //
          socketProvider.messageList.sort((b, a) {
            return a.chat_message_list.last.sent_at.compareTo(b.chat_message_list.last.sent_at);
          });
          break;
        }
      }*/

      return jsonData;
    }
  }

  // Future addChatMessage(String message, String senderId, String receiverId, String chatId) async {
  //     var url = Uri.parse("http://192.168.1.252/kadingira/addChatMessage.php");
  //     var request = await http.MultipartRequest("POST", url);
  //     // request.fields['id'] = widget.postList[widget.index]['id'];
  //
  //     request.fields['chat_id'] = chatId;
  //     request.fields['receiver_id'] = receiverId.toString();
  //     request.fields['sender_id'] = senderId.toString();
  //     request.fields['text'] = message.toString();
  //
  //     var response = await request.send();
  //
  //     if (response.statusCode >= 200 && response.statusCode < 400) {
  //       // Fluttertoast.showToast(
  //       //   msg: "Post aggiornato",
  //       // );
  //       //print(200);
  //     }
  // }

  // Connect the frontend to the backend URL
  void connect() {
    // connesso = true;

      socket!.on(
        "typing",
        (msg) {
          //print(msg);
          // chatProvider.isTyping = true;
          // chatProvider.testoRicevuto = msg['text'];
          setState(() {
            //TODO: aggiornare queste variabili nel chatProvider
            _isTyping = true;
            // testoRicevuto = msg['text'];
          });
        },
      );

      socket!.on(
        "stop_typing",
            // chatId,
        (msg) {
          //print(msg);

          setState(() {
            //TODO: aggiornare queste variabili nel chatProvider
            _isTyping = false;
          });
        },
      );
  }

  void join() {
    // socket.emit("join-chat", chatId);
    socket!.emit("join-chat", widget.chatId);
  }

  Future<void> sendMessage({
    String? message, String? senderId, String? receiverId, String? senderUsername, String? senderProfileImage
  }) async {
    // setMessage(
    //     type: "source",
    //     message: message
    // );
    // socket.emit("join-chat", chatId);

    // var socketProvider = Provider.of<SocketProvider>(context, listen: false);
    // //print(socket.connected.toString());

    //print('aId 999');
    //print(widget.aId);
    //print('bId 999');
    //print(widget.bId);

    DateTime sentAt = DateTime.now();

    // socket.emit(
    socket!.emitWithAck(
      "send-message",
      {
        "content": message,
        "senderId": senderId,
        "senderUsername": senderUsername,
        "senderProfileImage": senderProfileImage,
        "receiverId": receiverId,
        "chatId": socketProvider.chatId,
        "sentAt": sentAt.toString(),
        "user_a_id": widget.aId.toString(),
        "user_b_id": widget.bId.toString(),
        // "user_a_last_opening": user_a_last_opening_at.toString(),
        // "user_b_last_opening": user_b_last_opening_at.toString(),
      },
      ack: (data) {
        //print('ack1 $data') ;
        if (data != null) {
          //print('from server cladder 1 $data');
        }
        else {
          //print("Nullabbole 1") ;
        }
      }
        // ]
    );

    socket!.emitWithAck(
        "broadcast-test",
        'intralliJ',
        ack: (data) {
          //print('ack $data') ;
          if (data != null) {
            //print('from server cladder $data');
          }
          else {
            //print("Nullabbole") ;
          }
        }
    );

    socketProvider.addChatMessage(
        ChatMessage(
          text: message,
          receiver_id: receiverId,
          sender_id: senderId,
          // chatId: chatId.toString(),
          chat_id: widget.chatId.toString(),
          sent_at: sentAt,
          type: 'source',
          is_visible_for_sender: 1,
          is_visible_for_receiver: 1,
          // send_at: DateTime.now(),
          // send_at:
        )
    );

    // socketMessages.add(
    //   new ChatMessage(
    //     text: message,
    //     receiver_id: receiverId,
    //     sender_id: senderId,
    //     // chatId: chatId.toString(),
    //     chat_id: widget.chatId.toString(),
    //     sent_at: sentAt,
    //     type: 'source',
    //     is_visible_for_sender: 1,
    //     is_visible_for_receiver: 1,
    //   )
    // );

    /*for(var e in socketProvider.messageList){
      // if(e.chat_id.toString() == chatId.toString()){
      if(e.chat_id.toString() == widget.chatId.toString()){
        // socketProvider.messageList.remove(e);
        // socketProvider.messageList.add(
        //     new Chat(
        //       // chat_id: chatId,
        //       chat_id: int.tryParse(widget.chatId),
        //       receiver_id: receiverId,
        //       sender_id: widget.user.id,
        //       receiver_username: widget.receiverUsername,
        //       sender_username: widget.user.username,
        //       sent_at: DateTime.now().toLocal(),
        //       text: message,
        //       receiver_profile_image: widget.receiverProfileImage,
        //       sender_profile_image: widget.user.profile_image,
        //       user_a_id: widget.aId,
        //       user_b_id: widget.bId,
        //       // user_a_last_opening_at: user_a_last_opening_at,
        //       // user_b_last_opening_at: user_b_last_opening_at,
        //     )
        // );

        e.chat_message_list.add(
            ChatMessage(
              // id: msg['chatId'],
              text: message,
              receiver_id: receiverId,
              chat_id: widget.chatId,
              sender_id: widget.user.id,
              sent_at: sentAt.toLocal(),
              type: 'source',
              is_visible_for_sender: 1,
              is_visible_for_receiver: 1,
            )
        );
        // e.unread_messages++;

        // //print('tttttt');
        for(var e in socketProvider.messageList){
          e.chat_message_list.sort((a, b) {
            // return a.sent_at.compareTo(b.sent_at);
            return a.sent_at.compareTo(b.sent_at);
          });
          // //print(e.chat_message_list.last.text);
          // //print(e.chat_message_list.last.sent_at.toString());
        }
        //
        socketProvider.messageList.sort((b, a) {
          return a.chat_message_list.last.sent_at.compareTo(b.chat_message_list.last.sent_at);
        });
        break;
      }
    }*/

    // socketProvider.messageList.sort((b, a) {
    //   return a.sent_at.compareTo(b.sent_at);
    // });

    // //print('tttttt');
    // for(var e in socketProvider.messageList){
    //   // e.chat_message_list.sort((b, a) {
    //   //   return a.sent_at.compareTo(b.sent_at);
    //   // });
    //   //print(e.chat_message_list.last.text);
    //   //print(e.chat_message_list.last.sent_at.toString());
    // }
    //
    // socketProvider.messageList.sort((b, a) {
    //   return a.chat_message_list.last.sent_at.compareTo(b.chat_message_list.last.sent_at);
    // });

    // await insertChatMessage(message, senderId, receiverId, socketProvider.chatId.toString(), sentAt);

    // _textController.clear();
  }

  // void receiveMessage(/*String message, int senderId, int receiverId*/) {
  //   var chatProvider = Provider.of<ChatProvider>(context, listen: false);
  //
  //   chatProvider.socket.on(
  //         "receive-message",
  //         // "message",
  //         (msg) {
  //           // var chatProvider = Provider.of<ChatProvider>(context, listen: false);
  //
  //           //print(msg);
  //
  //           // Call the set Message function
  //           setMessage("destination", msg["content"]);
  //           chatProvider.addMessage(
  //               new MessageModel(
  //                 message: msg["content"],
  //                 // time:,
  //               )
  //           );
  //           //print("chatProvider.chatList");
  //           //print(chatProvider.chatList);
  //           // Scroll to Bottom
  //           _scrollController.animateTo(
  //             _scrollController.position.maxScrollExtent,
  //             duration: Duration(milliseconds: 300),
  //             curve: Curves.easeOut,
  //           );
  //         },
  //       );
  // }

  // Whenever a message is sent, set the state


  // void setMessage({String type, String message, String userId, String username, String profileImage}) {
  //   // var notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
  //
  //   MessageModel messageModel = MessageModel(
  //     type: type,
  //     message: message,
  //     time: DateTime.now().toString()/*.substring(10, 16)*/,
  //     senderId: userId,
  //     senderProfileImage: profileImage,
  //     senderUsername: username,
  //
  //
  //   );
  //   setState(() {
  //     socketMessages.add(messageModel);
  //     // if(messageModel.type == "destination") {
  //     //
  //     // }
  //   });
  //
  //   // //print("messages: ");
  //   // for (var m in socketMessages){
  //   //   //print(m.message.toString());
  //   // }
  // }

  // void _onTyping() {
  //   // socket.emit('typing', chatId);
  //   socket.emit(
  //       'typing',
  //       {
  //         "sender_id": widget.user.id,
  //         "chat": chatId,
  //         "text": _textController.text,
  //       }
  //   );
  // }

  // void _onStopTyping() {
  //   // socket.emit('stop_typing', chatId);
  //   socket.emit(
  //       'stop_typing',
  //       {
  //         "chat": chatId,
  //         "text": _textController.text,
  //       }
  //   );
  // }

  void _runTimer() {
    // var chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (_typingTimer != null && _typingTimer!.isActive)
        _typingTimer!.cancel();
    _typingTimer = Timer(
        Duration(milliseconds: /*2000*/1),
        () {
          if (!_isTyping)
              return;
          _isTyping = false;
          // chatProvider.isTyping = false;
          // _onStopTyping();
          // chatProvider.onStopTyping(
          //   text: _textController.text,
          //   chatId: int.parse(chatId)
          // );
        }
    );
    _isTyping = true;
    // chatProvider.isTyping = true;
    // _onTyping();
    // chatProvider.onTyping(
    //     text: _textController.text,
    //     chatId: int.parse(chatId)
    // );
  }

  void _showDeletingDialog(String module, String senderId, String receiverId, String text, DateTime sentAt) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return CustomDialog(
            title: 'Elimina questo messaggio',
            content: module,
            confirmColor: Colors.red[400],
            isCancel: true,
            confirmContent: 'Elimina',
            confirmCallback: (){
              deleteChatMessage(
                  text,
                  senderId,
                  receiverId,
                  sentAt
              );

              // cancelAppointment();
              // //print('Appuntamento cancellato');
            },

            // image: 'https://images.pexels.com/photos/3268732/pexels-photo-3268732.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
            // cancelColor: Colors.red[400],
          );
        }
    );
  }

  Widget btn2(BuildContext context) {
    return InkWell(
      // color: Colors.grey[300],
      // minWidth: 300,
      onTap: () => Dialogs.materialDialog(
          msg: 'Modifica messaggio',
          msgStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800
          ),
          // title: "Modifica messaggio",
          color: Colors.white,
          context: context,
          // useSafeArea: false,
          actions: [
            Column(
              children: [
                SingleChildScrollView(
                    child: Container(
                      height: 100,
                      child: Flexible(
                        child: TextField(
                          controller: _editChatTextController,
                          autofocus: false,
                          expands: true,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey[800],
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            hintText: "Scrivi il tuo messaggio...",
                            hintStyle: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey[500],
                            ),
                          ),
                          maxLines: null,
                        ),
                      ),
                    )
                ),
                IconsButton(
                  onPressed: () {

                  },
                  text: "Modifica",
                  iconData: Icons.edit_sharp,
                  color: Colors.blue[500],
                  textStyle: TextStyle(color: Colors.white),
                  iconColor: Colors.white,
                ),
                IconsOutlineButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // FocusScope.of(context).unfocus();
                    // FocusScope.of(context).requestFocus(FocusNode());
                    // setState(() {
                    //   FocusBusiness.instance.primaryFocus.unfocus();
                    //
                    // });

                  },
                  text: 'Annulla',
                  iconData: Icons.cancel_outlined,
                  textStyle: TextStyle(color: Colors.grey),
                  iconColor: Colors.grey,
                ),
              ],
            ),
            // IconsOutlineButton(
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            //   text: 'Cancel',
            //   iconData: Icons.cancel_outlined,
            //   textStyle: TextStyle(color: Colors.grey),
            //   iconColor: Colors.grey,
            // ),
            // IconsButton(
            //   onPressed: () {},
            //   text: "Delete",
            //   iconData: Icons.delete,
            //   color: Colors.red,
            //   textStyle: TextStyle(color: Colors.white),
            //   iconColor: Colors.white,
            // ),
          ]),
          child: Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: Icon(
                // SimpleLineIcons.options_vertical,
                Icons.edit_outlined,
                size: 26,
                color: Colors.grey[600],
              ),
            ),
          );
      // child: Text("Show Material Dialog"),

  }

  Future _loadMore() async {
    setState(() {
      isLoading = true;
    });

    // await new Future.delayed(const Duration(seconds: 2));
    // for (var i = currentLength; i <= currentLength + increment; i++) {
    //   chatMessages.add(i);
    // }
    for(var e in socketProvider.messageList){
      if(e.chat_id.toString() == widget.chatId.toString()){
        //print('ciaollll11111');
        for(int i = currentLength; i <= currentLength + increment; i++) {
          chatMessages.add(e.chat_message_list![i]);
        }
        // for(var e1 in e.chat_message_list){
        // // for(; chatMessageLoadedIndex < chatMessageToLoad; chatMessageLoadedIndex++){
        //   setState(() {
        //     // chatMessages.add(e.chat_message_list[chatMessageLoadedIndex]);
        //     chatMessages.add(e1);
        //   });
        // }
      }
    }

    setState(() {
      isLoading = false;
      currentLength = chatMessages.length;
    });
  }

  @override
  /*Future<void>*/void initState() /*async*/ {
    super.initState();
    initializeDateFormatting();

    socketProvider = Provider.of<SocketProvider>(context, listen: false);


    // _loadMore();
    // for(var e in socketProvider.messageList){
    //   if(e.chat_id.toString() == widget.chatId.toString()){
    //     chatMessagesLength = e.chat_message_list.length;
    //   }
    // }

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   timer = new Timer.periodic(
    //       Duration(seconds: 1),
    //           (Timer timer) {
    //         int chatMessageToLoad = chatMessageLoadedIndex + 15;
    //         //print('ciaollllooooo');
    //         //print(chatMessages.length);
    //         for(var e in socketProvider.messageList){
    //           if(e.chat_id.toString() == widget.chatId.toString()){
    //             //print('ciaollll11111');
    //             for(; chatMessageLoadedIndex < chatMessageToLoad; chatMessageLoadedIndex++){
    //               setState(() {
    //                 chatMessages.add(e.chat_message_list[chatMessageLoadedIndex]);
    //               });
    //             }
    //           }
    //         }
    //       }
    //   );
    // });

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   for(var e in socketProvider.messageList){
    //     if(e.chat_id.toString() == widget.chatId.toString()){
    //       //print('ciaollll11111');
    //       for(var e1 in e.chat_message_list){
    //       // for(; chatMessageLoadedIndex < chatMessageToLoad; chatMessageLoadedIndex++){
    //         setState(() {
    //           // chatMessages.add(e.chat_message_list[chatMessageLoadedIndex]);
    //           chatMessages.add(e1);
    //         });
    //       }
    //     }
    //   }
    // });
    //print('chatMessages.length');
    //print(chatMessages.length);


    // //print("aId00:" + widget.aId.toString());
    // //print("bId00:" + widget.bId.toString());

    // initialize();
    // focusNode.addListener(() {
    //   if (focusNode.hasFocus) {
    //     setState(() {
    //       show = false;
    //     });
    //   }
    // });
    // /*var*/ socketProvider = Provider.of<SocketProvider>(context, listen: false);

    // for(var e in socketProvider.messageList){
    //
    // }

    // // getChat().then((value) => updateLastOpeningChat());
    // updateLastOpeningChat();
    // // //print('chatId1111');
    // // //print(chatId);
    // //print('widget.chatId');
    // //print(widget.chatId);
    // // getAllUserChatMessage();
    // socketProvider.getAllChats(widget.user.id);
    // // socketProvider.getChatId(widget.user.id, aId, bId);
    // socketProvider.getChatId(widget.user.id, widget.aId, widget.bId);

    Future.wait([
      updateLastOpeningChat(),
      socketProvider.getAllChats(widget.user!.id),
      socketProvider.getChatId(widget.user!.id, widget.aId, widget.bId),
    ]);

    socket = socketProvider.socket;
    // if(connesso == false) {
    //   connect();
    //   setState(() {
    //     connesso = true;
    //   });
    // }

    // for(var e in socketProvider.messages){
    //   if(e.chatId.toString() == chatId.toString()){
    //     setState(() {
    //       socketMessages.add(e);
    //     });
    //   }
    // }
    // socketMessages.sort((a, b) {
    //   return a.send_at.compareTo(b.send_at);
    // });

    // socketProvider.isChatScreenOpen = true;
    socketProvider.chatScreenOpen = widget.chatId;

    // //print(socketProvider.socket.id);
    // //print(socket.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Future<void>/*void*/ dispose() async {
    super.dispose();
    await updateLastClosingChat();
    // timer.cancel();

    _textController.dispose();
    _scrollController.dispose();
    // socketProvider.isChatScreenOpen = false;
    socketProvider.chatScreenOpen = '';
    // socket.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    // var socketProvider = Provider.of<SocketProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);


    // socketMessages.clear();
    // for(var e in socketProvider.messages){
    //   // if(e.chatId.toString() == chatId.toString()){
    //   if(e.chat_id.toString() == widget.chatId.toString()){
    //     // setState(() {
    //     socketMessages.add(e);
    //     // });
    //   }
    // }
    // socketMessages.sort((a, b) {
    //   return a.sent_at.compareTo(b.sent_at);
    // });

    var reversedChatMessageList = [];

    // int ll = 0;
    for(var e in socketProvider.messageList){
      if(e.chat_id.toString() == widget.chatId.toString()){
        // ll = e.chat_message_list.length;
        reversedChatMessageList = List.from(e.chat_message_list!.reversed);
      }
    }

    // for(var e in socketProvider.messageList){
    //   if(e.chat_id.toString() == widget.chatId.toString()){
    //     chatMessagesLength = e.chat_message_list.length;
    //   }
    // }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      //backgroundColor: Theme.of(context).backgroundColor,
      backgroundColor: Colors.white,
      appBar: !isActiveEditableAppbar ?
      PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: AppBar(
          iconTheme: IconThemeData(
            color: Colors.grey[400], //change your color here
          ),
          elevation: 1,
          title: Row(
            children: [
              // ClipRRect(
              //   borderRadius:
              //   BorderRadius.circular(8),
              //   child: Image(
              //     image: CachedNetworkImageProvider(
              //       widget.receiverImage,
              //     ),
              //     width: 30,
              //     height: 30,
              //     fit: BoxFit.cover,
              //   ),
              // ),
              Container(
                child: Padding(
                  padding: EdgeInsets.only(left: 10, top: 2.5, bottom: 2.5),
                  child: Container(
                    width: 45,
                    height: 45,
                    // height: 20,
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 5,
                      // child: Image.network(
                      child: FutureImage(
                        widget.receiverProfileImage!,
                        width: MediaQuery.of(context).size.width,
                      ),
                      //margin: EdgeInsets.all(10),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@' + widget.receiverUsername!,
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                  SizedBox(height: 2.5,),
                  Text(
                    'Online',
                    style: TextStyle(
                      // color: Colors.grey[700],
                        color: Colors.green[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          // title: Text(
          //   testoRicevuto ?? "",
          //   style: TextStyle(
          //     color: Colors.black,
          //     fontSize: 12
          //   ),
          // ),
          // leading:
          actions: <Widget>[
            InkWell(
              onTap: () {
                // _bottomSheetOptions(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                //todo:
                child: Icon(
                  // SimpleLineIcons.options_vertical,
                  Icons.more_vert,
                  size: 17,
                  color: Colors.grey[600],
                ),
              ),
            ),
            // Container(
            //   child: Padding(
            //     padding: EdgeInsets.only(left: 10, top: 2.5, bottom: 2.5),
            //     child: Container(
            //       width: 50,
            //       // height: 20,
            //       child: Card(
            //         semanticContainer: true,
            //         clipBehavior: Clip.antiAliasWithSaveLayer,
            //         child: Image.network(
            //           widget.receiverImage,
            //           fit: BoxFit.cover,
            //         ),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(12.0),
            //         ),
            //         elevation: 15,
            //         //margin: EdgeInsets.all(10),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ) :
      PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: AppBar(
          iconTheme: IconThemeData(
            color: Colors.grey[600], //change your color here
          ),
          leading: InkWell(
            onTap: () {
              setState(() {
                isActiveEditableAppbar = false;
              });

            },
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.only(right: 10, left: 15),
              child: Icon(
                // SimpleLineIcons.options_vertical,
                Icons.clear,
                size: 26,
                color: Colors.grey[600],
              ),
            ),
          ),
          elevation: 1,
          // centerTitle: true,
          backgroundColor: Colors.white,
          actions: <Widget>[
            InkWell(
              onTap: () {
                setState(() {
                  isActiveEditableAppbar = false;
                  _editChatTextController.text = selectedChatMessage!.text!;
                });
                Dialogs.materialDialog(
                    msg: 'Modifica messaggio',
                    msgStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800
                    ),
                    // title: "Modifica messaggio",
                    color: Colors.white,
                    context: context,
                    barrierDismissible: true,
                    useRootNavigator: true,
                    // useSafeArea: false,
                    actions: [
                      Column(
                        children: [
                          SingleChildScrollView(
                            child: Container(
                              height: 70,
                              child: TextField(
                                controller: _editChatTextController,
                                autofocus: false,
                                expands: true,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey[800],
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10.0),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  hintText: "Scrivi il tuo messaggio...",
                                  hintStyle: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                maxLines: null,
                              ),
                            )
                          ),
                          IconsButton(
                            onPressed: () {
                              editChatMessage(
                                selectedChatMessage!.text,
                                selectedChatMessage!.sender_id,
                                selectedChatMessage!.receiver_id,
                                selectedChatMessage!.sent_at,
                                _editChatTextController.text
                              ).then((value) => Navigator.of(context, rootNavigator: true).pop());

                            },
                            text: "Modifica",
                            iconData: Icons.edit_sharp,
                            color: Colors.blue[500],
                            textStyle: TextStyle(color: Colors.white),
                            iconColor: Colors.white,
                          ),
                          IconsOutlineButton(
                            onPressed: () {
                              // Navigator.of(context).pop();
                              Navigator.of(context, rootNavigator: true).pop();
                              // FocusScope.of(context).unfocus();
                              // FocusScope.of(context).requestFocus(FocusNode());
                              // setState(() {
                              //   FocusBusiness.instance.primaryFocus.unfocus();
                              //
                              // });

                            },
                            text: 'Annulla',
                            iconData: Icons.cancel_outlined,
                            textStyle: TextStyle(
                                color: Colors.grey,

                            ),
                            iconColor: Colors.grey,
                          ),
                        ],
                      ),
                      // IconsOutlineButton(
                      //   onPressed: () {
                      //     Navigator.of(context).pop();
                      //   },
                      //   text: 'Cancel',
                      //   iconData: Icons.cancel_outlined,
                      //   textStyle: TextStyle(color: Colors.grey),
                      //   iconColor: Colors.grey,
                      // ),
                      // IconsButton(
                      //   onPressed: () {},
                      //   text: "Delete",
                      //   iconData: Icons.delete,
                      //   color: Colors.red,
                      //   textStyle: TextStyle(color: Colors.white),
                      //   iconColor: Colors.white,
                      // ),
                    ]);
              },
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(right: 10, left: 10),
                child: Icon(
                  // SimpleLineIcons.options_vertical,
                  Icons.edit_outlined,
                  size: 26,
                  color: Colors.grey[600],
                ),
              ),
            ),
            // btn2(context),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                Dialogs.materialDialog(
                    msg: 'Vuoi eliminare definitivamente questo messaggio?',
                    title: "Elimina messaggio",
                    color: Colors.white,
                    context: context,
                    actions: [
                      IconsOutlineButton(
                        onPressed: () {
                          // Navigator.of(context).pop();
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        text: 'Annulla',
                        iconData: Icons.cancel_outlined,
                        textStyle: TextStyle(color: Colors.grey),

                        iconColor: Colors.grey,
                      ),
                      IconsButton(
                        onPressed: () {
                          deleteChatMessage(
                              selectedChatMessage!.text,
                              selectedChatMessage!.sender_id,
                              selectedChatMessage!.receiver_id,
                              selectedChatMessage!.sent_at
                          ).then((value) => Navigator.of(context, rootNavigator: true).pop());
                        },
                        text: "Elimina",
                        iconData: Icons.delete,
                        color: Colors.red,
                        textStyle: TextStyle(color: Colors.white),
                        iconColor: Colors.white,
                      ),
                    ]);
                // _showDeletingDialog(
                //   "Sei sicuro di voler eliminare questo messaggio sia per te che per l'altro utente?",
                //   selectedChatMessage.sender_id,
                //   selectedChatMessage.receiver_id,
                //   selectedChatMessage.text,
                //   selectedChatMessage.sent_at,
                // );
                setState(() {
                  // selectedChatMessage = null;
                  isActiveEditableAppbar = false;
                });
              },
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(right: 10, left: 10),
                child: Icon(
                  // SimpleLineIcons.options_vertical,
                  Icons.delete_outline,
                  size: 26,
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topRight,
        //     end: Alignment.bottomLeft,
        //     colors: [
        //       Colors.black,
        //       Colors.grey,
        //     ],
        //   ),
        // ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
            reverse: true,
            padding: EdgeInsets.only(bottom: 55),
            // reverse: false,
            shrinkWrap: false,
            controller: _scrollController,
            physics: BouncingScrollPhysics(),//FixedExtentScrollPhysics(),
            // itemCount: socketMessages.length,
            // itemCount: socketProvider.messages.length,
            // itemCount: widget.messages.length,
            // itemCount: ll > 40 ? 40 : ll,
            // itemCount: ll,
            itemCount: reversedChatMessageList.length,
            // itemCount: chatMessagesLength,
            // itemCount: chatMessages.length,
            // itemCount: 15,
            itemBuilder: (context, index) {
              if(reversedChatMessageList[index].sender_id == widget.user!.id) {
                // //print("messages: ");
                // //print(messages[index].message.toString());
                // //print("socketMessages[index].message");
                // //print(socketMessages[index].message);
                // //print("socketProvider.messages[index].text");
                // //print(socketProvider.messages[index].text);
                if(reversedChatMessageList[index].is_visible_for_sender == 1){
                  return InkWell(
                    onLongPress: (){
                      selectedChatMessage = ChatMessage(
                        sender_id: reversedChatMessageList[index].sender_id,
                        receiver_id: reversedChatMessageList[index].receiver_id,
                        text: reversedChatMessageList[index].text,
                        sent_at: reversedChatMessageList[index].sent_at,
                      );
                      setState(() {
                        isActiveEditableAppbar = true;
                      });
                      // btn1(
                      //   context,
                      //   e.chat_message_list[index].sender_id,
                      //   e.chat_message_list[index].receiver_id,
                      //   e.chat_message_list[index].text,
                      //   e.chat_message_list[index].sent_at,
                      // );


                      // _showDeletingDialog(
                      //     "Sei sicuro di voler eliminare questo messaggio sia per te che per l'altro utente?",
                      //     e.chat_message_list[index].sender_id,
                      //     e.chat_message_list[index].receiver_id,
                      //     e.chat_message_list[index].text,
                      //     e.chat_message_list[index].sent_at,
                      //
                      // );
                    },
                    child: _buildSelfMessage(
                      // socketMessages[index].message,
                        reversedChatMessageList[index].text,
                        // socketMessages[index].time.toString().substring(11, 16),
                        // DateTime.parse(dbMessages[index]['sent_at'])
                        reversedChatMessageList[index].sent_at,
                        reversedChatMessageList[index].is_visualized
                      // text,
                      // time
                    ),
                  );
                }
                // return _buildSelfMessage(
                //   // socketMessages[index].message,
                //     e.chat_message_list[index].text,
                //     // socketMessages[index].time.toString().substring(11, 16),
                //     // DateTime.parse(dbMessages[index]['sent_at'])
                //     e.chat_message_list[index].sent_at
                //   // text,
                //   // time
                // );
              }
              // else if (widget.messages[index].type == "destination"){
              else if(reversedChatMessageList[index].receiver_id == widget.user!.id) {
                if(reversedChatMessageList[index].is_visible_for_receiver == 1) {
                  return _buildFriendMessage(
                    // socketMessages.last.message,
                    // socketMessages[index].message,
                      reversedChatMessageList[index].text,

                      // DateTime.now().toString().substring(11, 16),
                      // DateTime.now(),
                      reversedChatMessageList[index].sent_at
                    // text,
                    // time
                  );
                }
                //   return _buildFriendMessage(
                //   // socketMessages.last.message,
                //   // socketMessages[index].message,
                //     e.chat_message_list[index].text,
                //
                //     // DateTime.now().toString().substring(11, 16),
                //     // DateTime.now(),
                //     e.chat_message_list[index].sent_at
                //   // text,
                //   // time
                // );
              }
              return null;
            }

              // if (chatMessages[index].sender_id == widget.user.id) {
              //   // //print("messages: ");
              //   // //print(messages[index].message.toString());
              //   // //print("socketMessages[index].message");
              //   // //print(socketMessages[index].message);
              //   // //print("socketProvider.messages[index].text");
              //   // //print(socketProvider.messages[index].text);
              //   if (chatMessages[index].is_visible_for_sender == 1) {
              //     return InkWell(
              //       onLongPress: () {
              //         selectedChatMessage = new ChatMessage(
              //           sender_id: chatMessages[index].sender_id,
              //           receiver_id: chatMessages[index].receiver_id,
              //           text: chatMessages[index].text,
              //           sent_at: chatMessages[index].sent_at,
              //         );
              //
              //         setState(() {
              //           isActiveEditableAppbar = true;
              //         });
              //
              //         // btn1(
              //         //   context,
              //         //   e.chat_message_list[index].sender_id,
              //         //   e.chat_message_list[index].receiver_id,
              //         //   e.chat_message_list[index].text,
              //         //   e.chat_message_list[index].sent_at,
              //         // );
              //
              //
              //         // _showDeletingDialog(
              //         //     "Sei sicuro di voler eliminare questo messaggio sia per te che per l'altro utente?",
              //         //     e.chat_message_list[index].sender_id,
              //         //     e.chat_message_list[index].receiver_id,
              //         //     e.chat_message_list[index].text,
              //         //     e.chat_message_list[index].sent_at,
              //         //
              //         // );
              //       },
              //
              //       child: _buildSelfMessage(
              //         // socketMessages[index].message,
              //           chatMessages[index].text,
              //           // socketMessages[index].time.toString().substring(11, 16),
              //           // DateTime.parse(dbMessages[index]['sent_at'])
              //           chatMessages[index].sent_at,
              //           chatMessages[index].is_visualized
              //         // text,
              //         // time
              //       ),
              //     );
              //   }
              //   // return _buildSelfMessage(
              //   //   // socketMessages[index].message,
              //   //     e.chat_message_list[index].text,
              //   //     // socketMessages[index].time.toString().substring(11, 16),
              //   //     // DateTime.parse(dbMessages[index]['sent_at'])
              //   //     e.chat_message_list[index].sent_at
              //   //   // text,
              //   //   // time
              //   // );
              // }
              // // else if (widget.messages[index].type == "destination"){
              // else if (chatMessages[index].receiver_id == widget.user.id) {
              //   if (chatMessages[index].is_visible_for_receiver == 1) {
              //     return _buildFriendMessage(
              //       // socketMessages.last.message,
              //       // socketMessages[index].message,
              //         chatMessages[index].text,
              //
              //         // DateTime.now().toString().substring(11, 16),
              //         // DateTime.now(),
              //         chatMessages[index].sent_at
              //       // text,
              //       // time
              //     );
              //   }
              //   //   return _buildFriendMessage(
              //   //   // socketMessages.last.message,
              //   //   // socketMessages[index].message,
              //   //     e.chat_message_list[index].text,
              //   //
              //   //     // DateTime.now().toString().substring(11, 16),
              //   //     // DateTime.now(),
              //   //     e.chat_message_list[index].sent_at
              //   //   // text,
              //   //   // time
              //   // );
              // }
              // //print('i dont know');
              // return null;

              // if (isLoading && index == chatMessages.length - 1) {
              //   return Center(child: CircularProgressIndicator(),);
              // }
              // // return DemoItem(position);
              // if (chatMessages[index].sender_id == widget.user.id) {
              //   // //print("messages: ");
              //   // //print(messages[index].message.toString());
              //   // //print("socketMessages[index].message");
              //   // //print(socketMessages[index].message);
              //   // //print("socketProvider.messages[index].text");
              //   // //print(socketProvider.messages[index].text);
              //   if (chatMessages[index].is_visible_for_sender == 1) {
              //     return InkWell(
              //       onLongPress: () {
              //         selectedChatMessage = new ChatMessage(
              //           sender_id: chatMessages[index].sender_id,
              //           receiver_id: chatMessages[index].receiver_id,
              //           text: chatMessages[index].text,
              //           sent_at: chatMessages[index].sent_at,
              //         );
              //
              //         setState(() {
              //           isActiveEditableAppbar = true;
              //         });
              //
              //         // btn1(
              //         //   context,
              //         //   e.chat_message_list[index].sender_id,
              //         //   e.chat_message_list[index].receiver_id,
              //         //   e.chat_message_list[index].text,
              //         //   e.chat_message_list[index].sent_at,
              //         // );
              //
              //
              //         // _showDeletingDialog(
              //         //     "Sei sicuro di voler eliminare questo messaggio sia per te che per l'altro utente?",
              //         //     e.chat_message_list[index].sender_id,
              //         //     e.chat_message_list[index].receiver_id,
              //         //     e.chat_message_list[index].text,
              //         //     e.chat_message_list[index].sent_at,
              //         //
              //         // );
              //       },
              //
              //       child: _buildSelfMessage(
              //         // socketMessages[index].message,
              //           chatMessages[index].text,
              //           // socketMessages[index].time.toString().substring(11, 16),
              //           // DateTime.parse(dbMessages[index]['sent_at'])
              //           chatMessages[index].sent_at,
              //           chatMessages[index].is_visualized
              //         // text,
              //         // time
              //       ),
              //     );
              //   }
              //   // return _buildSelfMessage(
              //   //   // socketMessages[index].message,
              //   //     e.chat_message_list[index].text,
              //   //     // socketMessages[index].time.toString().substring(11, 16),
              //   //     // DateTime.parse(dbMessages[index]['sent_at'])
              //   //     e.chat_message_list[index].sent_at
              //   //   // text,
              //   //   // time
              //   // );
              // }
              // // else if (widget.messages[index].type == "destination"){
              // else if (chatMessages[index].receiver_id == widget.user.id) {
              //   if (chatMessages[index].is_visible_for_receiver == 1) {
              //     return _buildFriendMessage(
              //       // socketMessages.last.message,
              //       // socketMessages[index].message,
              //         chatMessages[index].text,
              //
              //         // DateTime.now().toString().substring(11, 16),
              //         // DateTime.now(),
              //         chatMessages[index].sent_at
              //       // text,
              //       // time
              //     );
              //   }
              //   //   return _buildFriendMessage(
              //   //   // socketMessages.last.message,
              //   //   // socketMessages[index].message,
              //   //     e.chat_message_list[index].text,
              //   //
              //   //     // DateTime.now().toString().substring(11, 16),
              //   //     // DateTime.now(),
              //   //     e.chat_message_list[index].sent_at
              //   //   // text,
              //   //   // time
              //   // );
              // }
              // //print('i dont know');
              // return null;
          // }
        ),
      ),
      // bottomSheet: Stack(
      //   children: [
      //     // MessageForm(
      //     //   // onSendMessage: /*_sendMessage*/,
      //     //   onTyping: _onTyping,
      //     //   onStopTyping: _onStopTyping,
      //     // ),
      //     Row(
      //       children: [
      //         Container(
      //           // margin: EdgeInsets.only(top: 150),
      //           width: MediaQuery.of(context).size.width - 60,
      //           child: Card(
      //             margin: EdgeInsets.only(
      //                 left: 2, right: 2, bottom: 8
      //             ),
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(10),
      //             ),
      //             child: TextFormField(
      //               controller: _textController,
      //               // focusNode: focusNode,
      //               // onChanged: (_) => _runTimer(),
      //
      //               textAlignVertical: TextAlignVertical.center,
      //               keyboardType: TextInputType.multiline,
      //               maxLines: 5,
      //               minLines: 1,
      //               // onChanged: (value) {
      //               //   if (value.length > 0) {
      //               //     setState(() {
      //               //       sendButton = true;
      //               //     });
      //               //   } else {
      //               //     setState(() {
      //               //       sendButton = false;
      //               //     });
      //               //   }
      //               // },
      //               decoration: InputDecoration(
      //                 border: InputBorder.none,
      //                 hintText: "Type a message",
      //                 // prefixIcon: IconButton(
      //                 //   icon: Icon(Icons.emoji_emotions),
      //                 //   onPressed: () {
      //                 //     setState(() {
      //                 //       focusNode.unfocus();
      //                 //       focusNode.canRequestFocus = false;
      //                 //       show = !show;
      //                 //     });
      //                 //   },
      //                 // ),
      //                 suffixIcon: Row(
      //                   mainAxisSize: MainAxisSize.min,
      //                   children: [
      //                     // IconButton(
      //                     // onPressed: () {
      //                     //   showModalBottomSheet(
      //                     //     backgroundColor:
      //                     //     Colors.transparent,
      //                     //     context: context,
      //                     //     builder: (builder) =>
      //                     //         bottomSheet(),
      //                     //   );
      //                     // },
      //                     //   icon: Icon(Icons.attach_file),
      //                     // ),
      //                     // IconButton(
      //                     //   onPressed: () {},
      //                     //   icon: Icon(Icons.camera_alt),
      //                     // ),
      //                   ],
      //                 ),
      //                 contentPadding: EdgeInsets.all(5),
      //               ),
      //             ),
      //           ),
      //         ),
      //         Padding(
      //           padding: const EdgeInsets.only(
      //             bottom: 8.0,
      //             right: 5,
      //             left: 2,
      //           ),
      //           child: CircleAvatar(
      //             radius: 25,
      //             backgroundColor: Color(0xFF128C7E),
      //             child: IconButton(
      //               icon: Icon(
      //                 Icons.send,
      //                 // sendButton ? Icons.send : Icons.mic,
      //                 color: Colors.white,
      //               ),
      //               onPressed: () async {
      //                 // if (sendButton) {
      //                 //   _scrollController.animateTo(
      //                 //     _scrollController
      //                 //         .position.maxScrollExtent,
      //                 //     duration: Duration(milliseconds: 300),
      //                 //     curve: Curves.easeOut,
      //                 //   );
      //                 //   sendMessage(
      //                 // await _showNotification();
      //                   sendMessage(
      //                     message: _textController.text,
      //                     // widget.sourceChat?.id,
      //                     senderId: widget.user.id,
      //                     // widget.chatModel.id,
      //                     receiverId: widget.user.id.toString() != widget.aId.toString()
      //                       ? widget.aId
      //                       : widget.bId,
      //                     senderProfileImage: widget.user.profile_image,
      //                     senderUsername: widget.user.username,
      //
      //                   );
      //
      //                   // Clear the text field
      //                   _textController.clear();
      //
      //                   testoRicevuto = "";
      //                   // chatProvider.testoRicevuto = '';
      //
      //                 // setState(() {
      //                   //   sendButton = false;
      //                   // });
      //                 // }
      //               },
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //     Visibility(
      //       visible: _isTyping,
      //       child: Padding(
      //         padding: const EdgeInsets.only(bottom: 50.0),
      //         child: Row(
      //           children: <Widget>[
      //             Text(
      //               // /*'$_userNameTyping */_textController.text,
      //               // /*'$_userNameTyping */testoRicevuto ?? "",
      //               /*'$_userNameTyping */'is typing',
      //               style: TextStyle(
      //                 color: Colors.black,
      //                 fontWeight: FontWeight.w400,
      //                 fontSize: 12,
      //               ),
      //             ),
      //             // Lottie.asset(
      //             //   'assets/animations/chat-typing-indicator.json',
      //             //   width: 40,
      //             //   height: 40,
      //             //   alignment: Alignment.bottomLeft,
      //             // ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      bottomSheet: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: 100,
            minHeight: 50
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.blue,
                ),
                onPressed: () {

                },
              ),
              Flexible(
                child: TextField(
                  controller: _textController,
                  autofocus: false,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[800],
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: "Scrivi il tuo messaggio...",
                    hintStyle: TextStyle(
                      fontSize: 15.0,
                      color: Colors.grey[500],
                    ),
                  ),
                  maxLines: null,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.blue,
                ),
                onPressed: () {
                  if(_textController.text != ''){
                  // if(_textController.text.isNotEmpty){
                    insertChatMessage(
                        _textController.text,
                        widget.user!.id,
                        widget.user!.id.toString() != widget.aId.toString()
                            ? widget.aId
                            : widget.bId,
                        socketProvider.chatId.toString(),
                        DateTime.now(),
                        widget.user!
                    );
                    // Clear the text field
                    _textController.clear();
                  }

                  // sendMessage(
                  //   message: _textController.text,
                  //   // widget.sourceChat?.id,
                  //   senderId: widget.user.id,
                  //   // widget.chatModel.id,
                  //   // receiverId: widget.user.id.toString() != aId.toString()
                  //   //   ? aId
                  //   //   : bId,
                  //   receiverId: widget.user.id.toString() != widget.aId.toString()
                  //       ? widget.aId
                  //       : widget.bId,
                  //   senderProfileImage: widget.user.profile_image,
                  //   senderUsername: widget.user.username,
                  // );

                },
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget emojiSelect() {
  //   return EmojiPicker(
  //     rows: 4,
  //     columns: 7,
  //     onEmojiSelected: (emoji, category) {
  //       //print(emoji);
  //       setState(() {
  //         _textController.text = _textController.text + emoji.emoji;
  //       });
  //     },
  //   );
  // }

  Widget _buildSelfMessage(String text, DateTime time, bool? isVisualized) {
    return Container(
      padding: EdgeInsets.only(
        top: 10.0,
        bottom: 10.0,
        left: 10.0,
        right: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // color: Colors.blue,
            constraints: BoxConstraints(
              //   minWidth: 100.0,
              //   maxWidth: MediaQuery.of(context).size.width * 0.9,
              // minHeight: 20,
              // maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //   begin: Alignment.topRight,
            //   end: Alignment.bottomLeft,
            //   colors: [
            //     Colors.blue,
            //     Colors.purple,
            //   ],
            // ),
            //   boxShadow: [
            //     BoxShadow(
            //         blurRadius: 0.05,
            //         // color: Colors.blue[500],
            //         color: Colors.black,
            //         // spreadRadius: 1,
            //     ),
            //   ],
            //   color: Color(0xFF1EA3E8),
              color: Color(0xFF4CA1F1).withOpacity(0.75),
              // color: Colors.greenAccent[400].withOpacity(0.55),
              // color: Colors.grey[700],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(12),
              ),
            ),
            padding: EdgeInsets.only(
              top: 12.0,
              // bottom: 5.0,
              bottom: 10.0,
              left: 16.0,
              right: 16,
            ),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 0,
                    right: 30,
                    top: 5,
                    bottom: 0,
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Text(
                      // time.toString()/*.substring(10, 16)*/,
                      DateFormat.MMMMd('it_IT').format(time)
                          + ' alle ' + time.toString().substring(11, 16),
                      style: TextStyle(
                          fontSize: 9.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    SizedBox(width: 6,),
                    Visibility(
                      visible: /*isVisualized*/false,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Icon(
                          Icons.check,
                          color: Colors.lightGreen[800],
                          // color: Colors.purple[700],
                          // color: Color(0xFF9894F4).withOpacity(0.9),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),

          ),
        ],
      ),
    );
  }

  Widget _buildFriendMessage(String text, DateTime time) {
    // /*await*/ _showNotification(text);
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 10.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            // color: Colors.blue,
            constraints: BoxConstraints(
                minWidth: 100.0,
                maxWidth: MediaQuery.of(context).size.width * 0.85,
              // minHeight: 20,
              // maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //   begin: Alignment.topRight,
              //   end: Alignment.bottomLeft,
              //   colors: [
              //     Colors.blue,
              //     Colors.purple,
              //   ],
              // ),
              //   boxShadow: [
              //     BoxShadow(
              //         blurRadius: 0.05,
              //         // color: Colors.blue[500],
              //         color: Colors.black,
              //         // spreadRadius: 1,
              //     ),
              //   ],
              // color: Colors.amber[300].withOpacity(1),
                color: Color(0xFF9894F4).withOpacity(0.9),
                // color: Colors.blue,

              // color: Colors.grey[700],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12.0),
                bottomRight: Radius.circular(0),
              ),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 5,
                    right: 0,
                    top: 5,
                    bottom: 0,
                  ),

                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                // RichText(
                //   text: TextSpan(
                //     // style: TextStyle(
                //     //   fontSize: 10.0,
                //     //   // height: 0.2,
                //     //   fontWeight: FontWeight.w700,
                //     //   color: Colors.blue,
                //     // ),
                //     children: <TextSpan>[
                //       TextSpan(
                //         text: text,
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 15
                //           // fontWeight: FontWeight.w500,
                //         ),
                //       ),
                //       // TextSpan(text: "\n" + time.toString(),),
                //     ],
                //   ),
                // ),
                Text(
                  // time.toString()/*.substring(10, 16)*/,
                  DateFormat.MMMMd('it_IT').format(time)
                      + ' alle ' + time.toString().substring(11, 16),
                  style: TextStyle(
                      fontSize: 9.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w500
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Future initialize() async {
  //   // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //   // AndroidInitializationSettings('ic_launcher');
  //   // AndroidInitializationSettings('launcher_icon');
  //   AndroidInitializationSettings('splash');
  //   final IOSInitializationSettings initializationSettingsIOS =
  //   IOSInitializationSettings(
  //     requestAlertPermission: false,
  //     requestBadgePermission: false,
  //     requestSoundPermission: false,
  //     // onDidReceiveLocalNotification:
  //     //     (int id, String title, String body, String payload) async {
  //     //   didReceiveLocalNotificationSubject.add(ReceivedNotification(
  //     //       id: id, title: title, body: body, payload: payload));
  //     // }
  //   );
  //   final InitializationSettings initializationSettings = InitializationSettings(
  //     android: initializationSettingsAndroid,
  //     iOS: initializationSettingsIOS,
  //     // macOS: initializationSettingsMacOS
  //   );
  //   flutterLocalNotificationsPlugin.initialize(initializationSettings);
  //
  // }
  //
  // Future<void> _showNotification(String body) async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //   AndroidNotificationDetails(
  //       'your channel id', 'your channel name', 'your channel description',
  //       importance: Importance.max,
  //       priority: Priority.max,
  //       enableLights: true,
  //       ledColor: Colors.white,
  //       enableVibration: true,
  //       ledOnMs: 100,
  //       ledOffMs: 100,
  //       playSound: true,
  //
  //       ticker: 'ticker'
  //   );
  //   var iosDetails = new IOSNotificationDetails();
  //   var generalNotificationDetails = new NotificationDetails(
  //       android: androidPlatformChannelSpecifics,
  //       iOS: iosDetails
  //   );
  //   // const NotificationDetails platformChannelSpecifics =
  //   // NotificationDetails(android: androidPlatformChannelSpecifics);
  //
  //   await flutterLocalNotificationsPlugin.show(
  //       0,
  //       'plain title',
  //       body,
  //       /*platformChannelSpecifics*/generalNotificationDetails,
  //       payload: 'item x'
  //   );
  // }

  /*Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        //color: Theme.of(context).backgroundColor,
        border: BorderDirectional(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              maxLines: null,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 20),
                hintText: "Type your message...",
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.only(left: 20, right: 0),
            icon: Icon(Icons.attach_file, color: Colors.grey[700]),
            onPressed: () {},
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.blue,
                size: 35,
              ),
            ),
          )
        ],
      ),
    );
  }*/
}
