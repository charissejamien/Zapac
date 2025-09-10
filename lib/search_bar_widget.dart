import 'package:flutter/material.dart';
import 'package:zapac/profile_page.dart';
import 'package:zapac/search_destination_page.dart';

class SearchBar extends StatefulWidget {
  final VoidCallback? onProfileTap;
  final Function(Map<String, dynamic>)? onPlaceSelected;

  const SearchBar({super.key, this.onProfileTap, this.onPlaceSelected});

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

  void _openSearchPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SearchDestinationPage(initialSearchText: ''),
      ),
    );

    if (result != null && widget.onPlaceSelected != null) {
      _handleSearchResult(result);
      widget.onPlaceSelected!(result);
    }
  }

  void _handleSearchResult(Map<String, dynamic> result) {
    if (result.containsKey('place')) {
      _searchController.text = result['place']['description'];
    } else if (result.containsKey('route')) {
      _searchController.text = result['route'].routeName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: ShapeDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2E2E2E)
            : const Color(0xFFD9E0EA),
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
                Icon(
                  Icons.search,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : const Color(0xFF6CA89A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    readOnly: true,
                    onTap: _openSearchPage,
                    decoration: const InputDecoration(
                      hintText: 'Where to?',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    cursorColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.onProfileTap?.call();
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
