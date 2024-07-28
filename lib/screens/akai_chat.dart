import 'dart:convert'; // For json encoding/decoding
import 'package:akai/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;
import 'package:akai/utils/constants/image_strings.dart';
import '../utils/constants/colors.dart';

import '../utils/constants/colors.dart'; // For making HTTP requests

List<ChatUser> _typingUsers =<ChatUser>[];
class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final ChatUser _currentUser =
  ChatUser(id: '1', firstName: 'Kayisha', lastName: 'Naidoo');
  final ChatUser _chatBot =
  ChatUser(id: '2', firstName: 'Akai', lastName: 'Chatbot',);
  List<ChatMessage> _messages = <ChatMessage>[];
  final String _apiEndpoint = 'https://akai-webapp-chfggua5dkb7g5bu.southafricanorth-01.azurewebsites.net/api/ai/chat'; // api endpoint
  //final String _bearerToken = 'YOUR_BEARER_TOKEN'; //auth token

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Akai AI Chat',
            style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: DashChat(
          messageOptions: MessageOptions(
            currentUserContainerColor: TColors.rosePink,
            currentUserTextColor: Colors.black,
            textColor: Colors.black,
            containerColor: Colors.white,

          ),
          currentUser: _currentUser,
          typingUsers: _typingUsers,
          onSend: (ChatMessage m) async {
            await getChatResponse(m);
          },
          messages: _messages,
          inputOptions: InputOptions(inputTextStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.normal)),
        ),
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_chatBot);
    });

    final requestBody = jsonEncode({
      'question': m.text,
    });

    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          //'Authorization': 'Bearer $_bearerToken', //Auth token
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String reply = data['response'].trim();

        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              text: reply,
              user: _chatBot,
              createdAt: DateTime.now(),
            ),
          );
        });
      } else if (response.statusCode == 401) {
        // Handle unauthorized error
        showErrorDialog('Authentication Error', 'You are not authorized to access this resource.');
      } else if (response.statusCode == 500) {
        // Handle server error
        showErrorDialog('Server Error', 'There was a problem with the server. Please try again later.');
      } else {
        // Handle other unexpected errors
        showErrorDialog('Unexpected Error', 'An unexpected error occurred. Please try again.');
      }
    } catch (e) {
      // Handle network or other errors
      showErrorDialog('Network Error', 'Failed to connect to the server. Please check your internet connection.');
    }
    setState(() {
      _typingUsers.remove(_chatBot);
    });
  }

  void showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
