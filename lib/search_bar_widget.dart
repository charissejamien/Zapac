import 'package:flutter/material.dart';
import 'package:zapac/profile_page.dart';

class SearchBar extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const SearchBar({super.key, this.onProfileTap});
  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: ShapeDecoration(
        color: const Color(0xFFD9E0EA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(70)),
        shadows: [
          BoxShadow(
            color: const Color(0xFF4A6FA5).withOpacity(0.4),
            blurRadius: 6.8,
            offset: const Offset(2, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF6CA89A)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Where to?',
                      hintStyle: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    onSubmitted: (value) =>
                        print('Search query submitted: $value'),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.onProfileTap?.call();
              print('Profile icon tapped!');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: Container(
              width: 34,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF6CA89A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_circle, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}