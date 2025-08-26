import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedSuggestionsPage extends StatelessWidget {
  const SavedSuggestionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Kaydedilen Öneriler',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('suggestions')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Henüz kaydedilmiş öneri yok.',
                style: TextStyle(fontSize: 18, color: Colors.green[800]),
              ),
            );
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              return _buildSuggestionCard(context, data);
            },
          );
        },
      ),
    );
  }
/*
  final TextEditingController _textController = TextEditingController();
Widget _send_message(){
return container(
child: Column(
 children:[
  row(
  const textfield(
   controller: textController,
),
  const Text("istenen veriyi girin")
   ),
]

)


);

}


*/
  Widget _buildSuggestionCard(BuildContext context, QueryDocumentSnapshot data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        collapsedBackgroundColor: Colors.green[100],
        backgroundColor: Colors.green[50],
        title: Text(
          data['text'] ?? '',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green[900],
            fontSize: 16,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              data['text'] ?? '',
              style: TextStyle(
                fontSize: 15,
                color: Colors.green[800],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red[400]),
                tooltip: 'Öneriyi Sil',
                onPressed: () async {
                  try {
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('suggestions')
                        .doc(data.id)
                        .delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Öneri başarıyla silindi.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Silme işlemi başarısız: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
