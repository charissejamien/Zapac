import 'package:flutter/material.dart';

// --- Dummy Data for Chat Messages ---
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
  const CommentingSection({super.key});

  @override
  State<CommentingSection> createState() => _CommentingSectionState();
}

class _CommentingSectionState extends State<CommentingSection> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final TextEditingController _commentController = TextEditingController();

  bool _isSheetFullyExpanded = false;
  String _selectedFilter = 'All';

  // MODIFIED: Updated dummy data to match the UI and include 'isMostHelpful'
  final List<ChatMessage> _chatMessages = [
    ChatMessage(
      sender: 'Zole Laverne',
      message:
          '“Ig 6PM juseyo, expect traffic sa Escariomida. Sakay nalang sa other side then walk to Ayala. Arraseo?”',
      route: 'Escario',
      timeAgo: '2 days ago',
      imageUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&h=500&fit=crop',
      likes: 15,
      isMostHelpful: true,
    ),
    ChatMessage(
      sender: 'Charisse Pempengco',
      message:
          '“Na agaw mog agi likod sa CDU kai na.... naay d mahimutang. Naa sya ddto mag atang”',
      route: 'Cebu Doc',
      timeAgo: '6 days ago',
      imageUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&h=500&fit=crop',
      likes: 8,
      dislikes: 1,
    ),
    ChatMessage(
      sender: 'Kyline Alcantara',
      message:
          '“Kuyaw kaaio sa Carbon. Naay nangutana nako ug wat nafen vela? why u crying again? unya nikanta ug thousand years.... kuyawa sa mga adik rn...”',
      route: 'Carbon',
      timeAgo: '9 days ago',
      imageUrl:
          'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=500&h=500&fit=crop',
      likes: 22,
      dislikes: 2,
    ),
    ChatMessage(
      sender: 'Adopted Brother ni Mikha Lim',
      message:
          '“Ang plete kai tag 12 pesos pero ngano si kuya driver nangayo ug 15 pesos? SMACK THAT.”',
      route: 'Lahug – Carbon',
      timeAgo: 'Just Now',
      imageUrl:
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&h=500&fit=crop',
      likes: 5,
    ),
    ChatMessage(
      sender: 'Unknown',
      message:
          '“Shortcut to terminal: cut through Gaisano Mall ground floor!!!!!!”',
      route: 'Puente',
      timeAgo: '1 week ago',
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop',
      dislikes: 7,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(() {
      if (_sheetController.size >= 0.85 && !_isSheetFullyExpanded) {
        setState(() => _isSheetFullyExpanded = true);
      } else if (_sheetController.size < 0.85 && _isSheetFullyExpanded) {
        setState(() => _isSheetFullyExpanded = false);
      }
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _commentController.dispose();
    super.dispose();
  }

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
                      setState(() {
                        _chatMessages.insert(
                          0,
                          ChatMessage(
                            sender: 'Kerropi',
                            message: '“${insightController.text.trim()}”',
                            route: routeController.text.trim(),
                            timeAgo: 'Just now',
                            imageUrl:
                                'https://cdn-icons-png.flaticon.com/512/100/100913.png',
                          ),
                        );
                      });
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

  void _toggleLike(int index) {
    setState(() {
      final message = _chatMessages[index];
      message.isLiked = !message.isLiked;
      message.likes += message.isLiked ? 1 : -1;
      if (message.isLiked && message.isDisliked) {
        message.isDisliked = false;
        message.dislikes -= 1;
      }
    });
  }

  void _toggleDislike(int index) {
    setState(() {
      final message = _chatMessages[index];
      message.isDisliked = !message.isDisliked;
      message.dislikes += message.isDisliked ? 1 : -1;
      if (message.isDisliked && message.isLiked) {
        message.isLiked = false;
        message.likes -= 1;
      }
    });
  }

  Widget _buildInsightCard(ChatMessage message, int index) {
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
                        Text(
                          message.sender,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (message.isMostHelpful)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
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
                        const Spacer(),
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
                                setState(() {
                                  _chatMessages.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Comment deleted.'),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Icon(
                            Icons.more_horiz,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(message.message, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      'Route: ${message.route}  |  ${message.timeAgo}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
                        color: message.isLiked ? Colors.blue : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        message.likes.toString(),
                        style: const TextStyle(fontSize: 12),
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
                        color: message.isDisliked ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        message.dislikes.toString(),
                        style: const TextStyle(fontSize: 12),
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
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF6CA89A),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black54,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF6CA89A)),
      ),
      showCheckmark: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.35,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
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
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4BE6C),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'Roboto',
                          ),
                          children: [
                            TextSpan(text: 'Taga '),
                            TextSpan(
                              text: 'ZAPAC',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4A6FA5),
                              ),
                            ),
                            TextSpan(text: ' says...'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFilterChip('All'),
                    _buildFilterChip('Warning'),
                    _buildFilterChip('Shortcuts'),
                    _buildFilterChip('Fare Tips'),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.black12),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: _chatMessages.length,
                  itemBuilder: (context, index) {
                    return _buildInsightCard(_chatMessages[index], index);
                  },
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.black12,
                    indent: 16,
                    endIndent: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
