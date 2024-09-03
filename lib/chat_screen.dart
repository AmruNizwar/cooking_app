import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  late FlutterTts _flutterTts;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool audioEnabled = true;

  @override
  void initState() {
    super.initState();
    _requestPermission(); // Request microphone permission
    _flutterTts = FlutterTts();
    _speech = stt.SpeechToText();
  }

  void _requestPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add({'message': message, 'sender': 'user'});
      _controller.clear();
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4:5000/chat'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reply = data['response'];
        setState(() {
          if (reply is List) {
            reply.forEach((recipe) {
              _messages.add({'message': recipe, 'sender': 'bot'});
            });
          } else {
            _messages.add({'message': reply, 'sender': 'bot'});
          }
        });

        if (audioEnabled) {
          _speak(reply is List ? reply.join(", ") : reply);
        }

        await _firestore.collection('chat_responses').add({
          'user_message': message,
          'bot_response': reply is List ? reply.join(", ") : reply,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        setState(() {
          _messages.add(
              {'message': 'Failed to connect to the server.', 'sender': 'bot'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'message': 'Error connecting to the server. Please try again later.',
          'sender': 'bot'
        });
      });
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  void _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) {
          print('onError: $val');
          setState(() {
            _isListening = false;
          });
          if (val.errorMsg == 'error_speech_timeout') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Speech recognition timed out. Please try again.')),
            );
          }
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
            });
          },
          listenFor: Duration(seconds: 120),
          pauseFor: Duration(seconds: 10),
          cancelOnError: true,
          partialResults: true,
        );
      } else {
        print("Speech recognition is not available");
        setState(() => _isListening = false);
      }
    } else {
      setState(() {
        _isListening = false;
        _speech.stop();
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
        actions: [
          IconButton(
            icon: Icon(audioEnabled ? Icons.volume_up : Icons.volume_off,
                color: Colors.black),
            onPressed: () {
              setState(() {
                audioEnabled = !audioEnabled;
              });
            },
          ),
        ],
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
            icon: Icon(
              Icons.mic,
              color: _isListening ? Colors.red : Colors.black,
              size: _isListening ? 36.0 : 24.0,
            ),
            onPressed: _toggleListening,
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
