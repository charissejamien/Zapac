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
        builder: (context) => const SearchDestinationPage(
          initialSearchText: '',
        ),
      ),
    );
    if (result != null && widget.onPlaceSelected != null) {
      widget.onPlaceSelected!(result);
    }
  }

  void _handleSearchResult(Map<String, dynamic> result) {
    if (result.containsKey('place')) {
      print('Selected place: ${result['place']['description']}');
      _searchController.text = result['place']['description']; // Display selected place
    } else if (result.containsKey('route')) {
      print('Selected route: ${result['route'].routeName}');
      _searchController.text = result['route'].routeName; // Display selected route
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: ShapeDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Color(0xFF2E2E2E)
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
                      : Color(0xFF6CA89A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  // Use TextField with readOnly: true and onTap to trigger navigation
                  child: TextField(
                    controller: _searchController,
                    readOnly: true, // This makes the TextField not editable directly
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchDestinationPage()),
                      );
                    }, // This will open the search page when tapped
                    decoration: InputDecoration(
                      hintText: 'Where to?',
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white54
                            : Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
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