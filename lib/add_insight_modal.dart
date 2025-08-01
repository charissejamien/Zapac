import 'package:flutter/material.dart';
import 'package:zapac/AuthManager.dart';
import 'package:zapac/commenting_section.dart'; // ChatMessage
import 'package:zapac/User.dart';

void showAddInsightModal({
  required BuildContext context,
  required ValueSetter<ChatMessage> onInsightAdded,
}) {
  // ① Grab the logged-in user once
  final user = AuthManager().currentUser!;
  final TextEditingController insightController = TextEditingController();
  final TextEditingController routeController   = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ② Use user's imageUrl and fullName
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    user.profileImageUrl ??
                    'https://cdn-icons-png.flaticon.com/512/100/100913.png',
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.firstName, // or user.fullName
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      'Posting publicly across ZAPAC',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: insightController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Share an insight to the community....',
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: routeController,
              decoration: InputDecoration(
                hintText: 'What route are you on?',
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                border: OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final text = insightController.text.trim();
                  final route = routeController.text.trim();
                  if (text.isNotEmpty && route.isNotEmpty) {
                    final newInsight = ChatMessage(
                      sender: user.firstName,  // dynamic
                      message: '“$text”',
                      route: route,
                      timeAgo: 'Just now',
                      imageUrl: user.profileImageUrl ??
                      'https://cdn-icons-png.flaticon.com/512/100/100913.png',
                    );
                    onInsightAdded(newInsight);
                    Navigator.pop(context);
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
  );
}