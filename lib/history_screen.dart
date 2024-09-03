import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange[100],
        title: Text('History', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chat_responses')
            .orderBy('timestamp', descending: true) // Ordering messages by time
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading history.'));
          }

          final historyItems = snapshot.data?.docs ?? [];

          if (historyItems.isEmpty) {
            return Center(
              child: Text(
                'No conversations found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Grouping messages by date
          Map<String, List<DocumentSnapshot>> groupedHistory = {};
          for (var doc in historyItems) {
            final date = (doc['timestamp'] as Timestamp).toDate();
            final dateString = DateFormat('dd/MM/yyyy').format(date);
            if (!groupedHistory.containsKey(dateString)) {
              groupedHistory[dateString] = [];
            }
            groupedHistory[dateString]!.add(doc);
          }

          return ListView.builder(
            itemCount: groupedHistory.keys.length,
            itemBuilder: (context, index) {
              final date = groupedHistory.keys.elementAt(index);
              final messages = groupedHistory[date]!;
              final preview = messages.first['user_message'] ?? 'No Message';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagesPage(
                        date: date,
                        messages: messages,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            preview,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MessagesPage extends StatelessWidget {
  final String date;
  final List<DocumentSnapshot> messages;

  MessagesPage({required this.date, required this.messages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages from $date'),
        backgroundColor: Colors.orange[100],
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final userMessage = message['user_message'] ?? 'No Message';
          final botResponse = message['bot_response'] ?? 'No Response';

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User: $userMessage',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text('Bot: $botResponse'),
                Divider(),
              ],
            ),
          );
        },
      ),
    );
  }
}
