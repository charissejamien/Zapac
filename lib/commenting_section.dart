import 'package:flutter/material.dart';

// --- Dummy Data for Chat Messages ---
// If ChatMessage is used elsewhere, consider moving it to lib/models/chat_message.dart
class ChatMessage {
  final String sender;
  final String message;
  final String route;
  final String timeAgo;
  final String imageUrl;
  int likes;
  int dislikes;
  bool isLiked;
  bool isDisliked;
  bool isMostHelpful;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.route,
    required this.timeAgo,
    required this.imageUrl,
    this.likes = 0,
    this.dislikes = 0,
    this.isLiked = false,
    this.isDisliked = false,
    this.isMostHelpful = false,
  });
}

class CommentingSection extends StatefulWidget {
  final ValueSetter<bool>? onExpansionChanged;
  final List<ChatMessage> chatMessages; // ADDED: Receive chat messages from parent
  final ValueSetter<ChatMessage>? onNewInsightAdded; // Optional: If CommentingSection's internal modal adds.

  const CommentingSection({
    super.key,
    this.onExpansionChanged,
    required this.chatMessages, // ADDED: Required to receive messages
    this.onNewInsightAdded,
  });

  @override
  State<CommentingSection> createState() => _CommentingSectionState();
}

class _CommentingSectionState extends State<CommentingSection> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final TextEditingController _commentController = TextEditingController();

  bool _isSheetFullyExpanded = false;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(() {
      final bool isExpandedNow = _sheetController.size >= 0.85;
      if (isExpandedNow != _isSheetFullyExpanded) {
        if (mounted) {
          setState(() {
            _isSheetFullyExpanded = isExpandedNow;
          });
        }
        widget.onExpansionChanged?.call(_isSheetFullyExpanded); // Call the callback if provided
      }
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // MODIFIED: _showAddInsightSheet (removed, as per previous context it's handled by Dashboard)
  // Re-adding a simple version for the button in case it's still intended for internal use,
  // but the primary add insight should come from Dashboard's FloatingButton.
  void _showAddInsightSheet() {
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
                      widget.onNewInsightAdded?.call(newInsight); // Notify parent if callback is provided
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
    ).whenComplete(() {
      insightController.dispose();
      routeController.dispose();
    });
  }


  void _toggleLike(int index) {
    if (mounted) {
      setState(() {
        final message = _filteredMessages[index]; // Use filtered list
        message.isLiked = !message.isLiked;
        message.likes += message.isLiked ? 1 : -1;
        if (message.isLiked && message.isDisliked) {
          message.isDisliked = false;
          message.dislikes -= 1;
        }
      });
    }
  }

  void _toggleDislike(int index) {
    if (mounted) {
      setState(() {
        final message = _filteredMessages[index]; // Use filtered list
        message.isDisliked = !message.isDisliked;
        message.dislikes += message.isDisliked ? 1 : -1;
        if (message.isDisliked && message.isLiked) {
          message.isLiked = false;
          message.likes -= 1;
        }
      });
    }
  }

  // NEW: Filtered messages list
  List<ChatMessage> get _filteredMessages {
    if (_selectedFilter == 'All') {
      return widget.chatMessages;
    }

    // Convert filter to lowercase for case-insensitive matching
    final filterLower = _selectedFilter.toLowerCase();

    return widget.chatMessages.where((message) {
      final messageLower = message.message.toLowerCase();
      final routeLower = message.route.toLowerCase();

      switch (filterLower) {
        case 'warning':
          // Example keywords for warnings
          return messageLower.contains('traffic') ||
                 messageLower.contains('danger') ||
                 messageLower.contains('kuyaw') || // Cebuano for 'dangerous'
                 messageLower.contains('beware') ||
                 messageLower.contains('agaw'); // Cebuano for 'snatch'
        case 'shortcuts':
          // Example keywords for shortcuts
          return messageLower.contains('shortcut') ||
                 messageLower.contains('agi likod') || // Cebuano for 'pass behind'
                 messageLower.contains('cut through') ||
                 messageLower.contains('faster route');
        case 'fare tips':
          // Example keywords for fare tips
          return messageLower.contains('plete') || // Cebuano for 'fare'
                 messageLower.contains('fare') ||
                 messageLower.contains('pesos') ||
                 messageLower.contains('piso');
        case 'driver reviews':
          // Example keywords for driver reviews (assuming 'driver' or 'kuya' in message)
          return messageLower.contains('driver') ||
                 messageLower.contains('kuya driver') || // "Kuya driver" (brother driver)
                 messageLower.contains('conduct'); // e.g., driver's conduct
        default:
          return true; // Should not happen if filter is one of the defined
      }
    }).toList();
  }

  Widget _buildInsightCard(ChatMessage message, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(message.imageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message.sender,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (message.isMostHelpful)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6CA89A).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '💡 Most Helpful',
                              style: TextStyle(
                                color: Color(0xFF6CA89A),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTapDown: (details) async {
                            final RenderBox overlay =
                                Overlay.of(context).context.findRenderObject()
                                    as RenderBox;
                            final List<PopupMenuEntry<String>> menuItems = [
                              const PopupMenuItem(
                                value: 'report',
                                child: Text('Report'),
                              ),
                            ];
                            if (message.sender == 'You') {
                              menuItems.add(
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              );
                            }
                            final result = await showMenu<String>(
                              context: context,
                              position: RelativeRect.fromRect(
                                details.globalPosition & const Size(40, 40),
                                Offset.zero & overlay.size,
                              ),
                              items: menuItems,
                            );
                            if (result == 'report') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reported.')),
                              );
                            } else if (result == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Comment'),
                                  content: const Text(
                                    'Are you sure you want to delete this comment?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                if (mounted) {
                                  // Call setState to update UI after deletion
                                  setState(() {
                                    // MODIFIED: Delete from the original list (widget.chatMessages)
                                    // To do this properly, the parent (Dashboard) should provide
                                    // a callback to remove the message from its list.
                                    // For now, removing directly from a copy in _filteredMessages
                                    // will cause issues if the filter changes later.
                                    // A better solution would be:
                                    // 1. Give CommentingSection a callback like `onMessageDeleted(ChatMessage)`
                                    // 2. Dashboard handles the actual deletion from its `_chatMessages` list
                                    // For this example, we'll simulate direct removal for simplicity
                                    // but be aware of this for state management in a larger app.

                                    // Find the original index of the message in the main list
                                    final originalIndex = widget.chatMessages.indexOf(message);
                                    if (originalIndex != -1) {
                                      widget.chatMessages.removeAt(originalIndex);
                                    }
                                  });
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Comment deleted.'),
                                  ),
                                );
                              }
                            }
                          },
                          child: Icon(
                            Icons.more_horiz,
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Route: ${message.route}  |  ${message.timeAgo}',
                      style: TextStyle(
                        color: textTheme.bodySmall?.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 61),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _toggleLike(index),
                  child: Row(
                    children: [
                      Icon(
                        message.isLiked
                            ? Icons.thumb_up
                            : Icons.thumb_up_alt_outlined,
                        color: message.isLiked ? Colors.blue : Theme.of(context).dividerColor,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        message.likes.toString(),
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                InkWell(
                  onTap: () => _toggleDislike(index),
                  child: Row(
                    children: [
                      Icon(
                        message.isDisliked
                            ? Icons.thumb_down
                            : Icons.thumb_down_alt_outlined,
                        color: message.isDisliked ? Colors.red : Theme.of(context).dividerColor,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        message.dislikes.toString(),
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (mounted && selected) {
            setState(() => _selectedFilter = label);
          }
        },
        backgroundColor: const Color(0xFF6CA89A),
        selectedColor: const Color(0xFF4A6FA5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
        showCheckmark: isSelected,
        checkmarkColor: Colors.white,
        avatar: isSelected
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Get the filtered list of messages
    final List<ChatMessage> currentMessages = _filteredMessages; // NEW: Use filtered messages

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.35,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFDBA252)
                      : const Color(0xFFF4BE6C),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.black : Colors.black,
                        fontFamily: 'Roboto',
                      ),
                      children: [
                        const TextSpan(text: 'Taga '),
                        TextSpan(
                          text: 'ZAPAC',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: colorScheme.primary,
                          ),
                        ),
                        const TextSpan(text: ' says...'),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 0.0,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Warning'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Shortcuts'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Fare Tips'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Driver Reviews'),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: currentMessages.length, // MODIFIED: Use the filtered list
                  itemBuilder: (context, index) {
                    return _buildInsightCard(currentMessages[index], index); // MODIFIED: Use the filtered list
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}