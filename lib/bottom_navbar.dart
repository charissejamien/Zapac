import 'package:flutter/material.dart';
import 'dashboard.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Color(0xFF4A6FA5),
        boxShadow: [BoxShadow(blurRadius: 4, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              widget.onItemTapped(0);
              // Example navigation back to Dashboard
              if (ModalRoute.of(context)?.settings.name != '/') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                );
              }
            },
            child: Icon(
              Icons.home,
              size: 30,
              color: widget.selectedIndex == 0
                  ? Colors.tealAccent[100]
                  : Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () => widget.onItemTapped(1),
            child: Icon(
              Icons.bookmark,
              size: 30,
              color: widget.selectedIndex == 1
                  ? Colors.tealAccent[100]
                  : Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () => widget.onItemTapped(2),
            child: Icon(
              Icons.menu,
              size: 30,
              color: widget.selectedIndex == 2
                  ? Colors.tealAccent[100]
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
