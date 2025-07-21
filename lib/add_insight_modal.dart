import 'package:flutter/material.dart';
import 'package:zapac/commenting_section.dart'; // Assuming ChatMessage is here or create a separate models/chat_message.dart

// This function will be called directly from Dashboard
void showAddInsightModal({
  required BuildContext context,
  required ValueSetter<ChatMessage> onInsightAdded,
}) {
  final TextEditingController insightController = TextEditingController();
  final TextEditingController routeController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/100/100913.png',
                  ),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kerropi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Posting publicly across ZAPAC',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: insightController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Share an insight to the community....',
                border: InputBorder.none,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: routeController,
              decoration: const InputDecoration(
                hintText: 'What route are you on?',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (insightController.text.trim().isNotEmpty &&
                      routeController.text.trim().isNotEmpty) {
                    final newInsight = ChatMessage(
                      sender: 'Kerropi',
                      message: '“${insightController.text.trim()}”',
                      route: routeController.text.trim(),
                      timeAgo: 'Just now',
                      imageUrl:
                          'https://cdn-icons-png.flaticon.com/512/100/100913.png',
                    );
                    onInsightAdded.call(newInsight); // Call the callback
                    Navigator.pop(context); // Close the modal
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6CA89A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('OK'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  ).whenComplete(() {
    // Dispose controllers when modal is closed
    insightController.dispose();
    routeController.dispose();
  });
}