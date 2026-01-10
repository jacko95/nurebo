import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:nurebo/models/ChatModel.dart';
import 'package:nurebo/models/MessageModel.dart';
import 'package:nurebo/models/cart_item.dart';
import 'package:nurebo/models/chat_message.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/models/chat_message.dart';
// import '../model/order.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;


class ChatProvider extends ChangeNotifier {
  List<ChatMessage> messages = [];
  late IO.Socket socket;
  List? chatList = [];
  bool? isTyping;
  String? testoRicevuto;
  var chatId;


  // ChatProvider(){
  //   //print("e['id']33333");
  //   for(var e in chatList){
  //     //print(e['id']);
  //     socket.emit("join-chat", e['id']);
  //   }
  // }

  Future getAllChats(String userId) async {
    var url = Uri.parse(Utils.httpServerUrl + "chat/user");

    Map/*<String, String>*/ body = {
      'user_id': userId,
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

    //print("response.statusCode8888:");
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   chat = jsonData;
      // });
      // //print("chat: ");
      // //print(chat.toString());
      // //print("jsonDataaaaaa");
      // //print(jsonData.toString());

      // //print("jsonData[0]['id']: ");
      // //print(jsonData[0]['id'].toString());

      // chatId = chat[0]['id'];
      // chatId = jsonData[0]['id'];
      // setState(() {
      chatList = jsonData;
      // });
      // //print("chatList: ");
      // //print(chatList);
      //print("chatList.length: " + chatList!.length.toString());
      notifyListeners();
      return jsonData;
    }
  }

  Future<void> connect() async {
    //da errore
    // var chatProvider = Provider.of<ChatProvider>(context);

    // Pass additional paramters
    // socket =
    //     IO.io(Constants.serverUrl + "", <String, dynamic>{
    //       // IO.io("https://polar-caverns-53061.herokuapp.com/", <String, dynamic>{
    //       "transports": ["websocket"],
    //       "autoConnect": false,
    //     });
    //
    // // Connect Socketio manually
    // socket.connect();
    //
    // // If it is connected
    // await socket.onConnect((data) {
    //   //print("Connected");
    //
    //   socket.on('greeting', (data) {
    //     //print(data);
    //     // Map<String, dynamic> d = data;
    //     // setState(() {
    //     //   // _users += d['user'];
    //     // });
    //   });
    //

    //   for(var chat in chatList){
    //     //print("chat['id']");
    //     //print(chat['id']);
    //     // socket.emit("join-chat", chat['id']);
    //     socket.emit(
    //         "join-chat",
    //         {
    //           "id": chat['id']
    //         }
    //     );
    //   }

      // socket.on(
      //     "isLogged",
      //         (msg) {
      //       //print("isLogged");
      //       //print(msg);
      //       if(msg != chatId){
      //         socket.emit("join-chat", chatId);
      //       }
      //     }
      // );

      // socket.emit("join-chat", chatId.toString());
      // socket.on(
      //     "isLogged",
      //     // "message",
      //     (msg) {
      //       //print("isLogged");
      //       //print(msg);
      //       // if(msg == null){
      //       //   socket.emit("join-chat", msg);
      //       // }
      //     }
      // );

      // Listen to the message event form
      // the server, which is triggered whenever
      // A message is recieved
      socket.on(
        "receive-message",
        // "message",
        (msg) {
          // var chatProvider = Provider.of<ChatProvider>(context, listen: false);

          //print(msg);
          // for(var chat in chatList){
          //   //print("chat['id']");
          //   //print(chat['id']);
          //   socket.emit("join-chat", chat['id']);
          // }


          // Call the set Message function
          // setMessage("destination", msg["content"]);

          addMessage(
            //non messagemodel, ma chat message con l'id di chi invia e chi riceve
            //per prendere l'id di chi invia e mostrare l'ultimo messaggio in messagesScreen
            //mettere anche il datetime.now() e prendere l'ultimo messaggio
            // con datetime maggiore
            //   new MessageModel(
          //     message: msg["content"],
          // ));
              ChatMessage(
                text: msg["content"],
                receiver_id: msg["receiver_id"],
                sender_id: msg['receiver_id'],
                // send_at:
              )
          );
          // Scroll to Bottom
          // _scrollController.animateTo(
          //   _scrollController.position.maxScrollExtent,
          //   duration: Duration(milliseconds: 300),
          //   curve: Curves.easeOut,
          // );
          notifyListeners();
        },
      );

      socket.on(
        "typing",
        (msg) {
          //print(msg);
          // setState(() {
          isTyping = false;
          testoRicevuto = msg['text'];
          // widget.realTimeText = msg['text'];
          // });
          notifyListeners();
        },
      );

      socket.on(
        "stop_typing",
        // chatId,
        (msg) {
          //print(msg);
          // setState(() {
            isTyping = false;
            testoRicevuto = msg['text'];
            // widget.realTimeText = msg['text'];
          // });
          notifyListeners();
        },
      );
    // });
    // notifyListeners();


    // Check if it's connected
    // //print(socket.connected);

    // Send the ID of the current user to the backend
    // socket.emit("signin", /*widget.sourceChat?.id*/widget.user.id);
  }

  // void addMessage(ChatMessage message) {
  //   final i = messages.indexWhere((e) => e.singleEventId == message.singleEventId);
  //   //print('i');
  //   //print(i);
  //   if (i > -1) {
  //     messages[i].quantity += ticket.quantity;
  //   } else {
  //     this.messages.add(ticket);
  //   }
  //   notifyListeners();
  // }

  // void onTyping({int chatId, String text}) {
  //   // socket.emit('typing', chatId);
  //   socket.emit(
  //       'typing',
  //       {
  //         "contenuto": 'non so',
  //         "chat": chatId,
  //         "text": text,
  //       }
  //   );
  //   notifyListeners();
  // }
  //
  // void onStopTyping({int chatId, String text}) {
  //   // socket.emit('stop_typing', chatId);
  //   socket.emit(
  //       'stop_typing',
  //       {
  //         "contenuto": 'non so',
  //         "chat": chatId,
  //         "text": text,
  //       }
  //   );
  //   notifyListeners();
  // }

  // void addMessage(MessageModel message) {
  void addMessage(ChatMessage message) {
      // for(var e in messages) {
      //   if (e. == message.ticketCategoryId) {
      //     // e.quantity += ticket.quantity;
      //     notifyListeners();
      //     return;
      //   }
      // }
      messages.add(message);
    // for(var e in items) {
    //   //print(e.toString());
    // }
    notifyListeners();
  }

  // Future getAllChats(String userId) async {
  //   // //print("aId:" + aId.toString());
  //   // //print("bId:" + bId.toString());
  //
  //   var url = Uri.parse(Constants.serverUrl + "chat/user");
  //
  //   Map/*<String, String>*/ body = {
  //     'user_id': userId,
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
  //   //print("response.statusCode8888:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // setState(() {
  //     //   chat = jsonData;
  //     // });
  //     // //print("chat: ");
  //     // //print(chat.toString());
  //     //print("jsonDataaaaaa");
  //     //print(jsonData.toString());
  //
  //     // //print("jsonData[0]['id']: ");
  //     // //print(jsonData[0]['id'].toString());
  //
  //     // chatId = chat[0]['id'];
  //     // chatId = jsonData[0]['id'];
  //     // setState(() {
  //       chatList = jsonData;
  //     // });
  //     // //print("chatList: ");
  //     // //print(chatList);
  //     //print("chatList.length: " + chatList.length.toString());
  //     notifyListeners();
  //     return jsonData;
  //   }
  // }

  removeMessage(MessageModel message) {
    // final i = items.indexWhere((e) => e.ticketCategoryId == ticket.ticketCategoryId);
    // items.remove(items[i]);
    // // if (i > -1) {
    // //   items[i].quantity += ticket.quantity;
    // // } else {
    // //   this.items.add(ticket);
    // // }
    //
    // // items.remove(ticket);
    // notifyListeners();
  }

  Future getChatId(String userId, String aId, String bId) async {

    //print("aId:" + aId.toString());
    //print("bId:" + bId.toString());
    // var url = Uri.parse("http://192.168.1.252/kadingira/getChat.php");
    //
    // var response = await http.post(
    //     url,
    //     body: {
    //       "a_id": this.widget.aId,
    //       "b_id": this.widget.bId,
    //     });
    var url = Uri.parse(Utils.httpServerUrl + "chat/users");

    Map/*<String, String>*/ body = {
      "a_id": aId,
      "b_id": bId,
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
      // setState(() {
      //   chat = jsonData;
      // });
      // //print("chat: ");
      // //print(chat.toString());
      //print("jsonData[0]['id']");
      //print(jsonData[0]['id'].toString());

      // chatId = chat[0]['id'];
      chatId = jsonData[0]['id'];
      //print("chatId: ");
      //print(chatId);
      getAllChats(userId);
      notifyListeners();
      return jsonData;
    }
  }

  Future getUsersLastMessage(String userA, String userB) async {
    //print('userA0');
    //print(userA);
    //print('userB0');
    //print(userB);
    var url = Uri.parse(Utils.httpServerUrl + "chat_message/last");

    Map/*<String, String>*/ body = {
      "user_a": userA,
      "user_b": userB,
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

    // //print("response.statusCode lastm:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // chatProvider.chatList = jsonData;
      // setState(() {
      //   chatList = jsonData;
      // });
      //print("jsonData last");
      //print(jsonData);
      // connect();
      // //print(chatList);
      // //print("chatList:");
      // //print(chatList);
      notifyListeners();
      return jsonData;
    }
  }

  // decrementQty(order) {
  //   final i = items.indexWhere((e) => e.product == order.product);
  //   if (items[i].qty == 1) {
  //     removeOrder(order);
  //   } else {
  //     items[i].qty -= 1;
  //     notifyListeners();
  //   }
  // }
  //
  // incrementQty(order) {
  //   items[items.indexOf(order)].qty += 1;
  //   notifyListeners();
  // }
}
