import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add({'message': message, 'sender': 'user'});
      _controller.clear();
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/get_recipe'), // Use your server's IP address
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'query': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');
        final reply = data['response'];
        setState(() {
          if (reply is List) {
            reply.forEach((recipe) {
              _messages.add({'message': recipe, 'sender': 'bot'}); // Display each recipe name
            });
          } else {
            _messages.add({'message': reply, 'sender': 'bot'});
          }
        });
      } else {
        setState(() {
          _messages.add(
              {'message': 'Failed to connect to the server.', 'sender': 'bot'});
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() { 
        _messages.add({
          'message': 'Error connecting to the server. Please try again later.',
          'sender': 'bot'
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange[100],
        title: Row(
          children: [
            Icon(Icons.chat_bubble, color: Colors.black),
            SizedBox(width: 8),
            Text(
              'Cook With Me',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _messages.map((msg) {
                  return _buildChatBubble(
                    context,
                    msg['message'] ?? '',
                    msg['sender'] == 'bot',
                  );
                }).toList(),
              ),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, String message, bool isBot) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        decoration: BoxDecoration(
          color: isBot ? Colors.grey[200] : Colors.black,
          borderRadius: isBot
              ? BorderRadius.only(
                  topRight: Radius.circular(15.0),
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0),
                )
              : BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0),
                ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isBot ? Colors.black : Colors.white,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: () {
              // Handle adding attachments
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: Icon(Icons.mic, color: Colors.black),
            onPressed: () {
              // Handle sending voice message
            },
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.black),
            onPressed: () {
              _sendMessage(_controller.text);
            },
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: ChatScreen(),
    ));
