// import 'package:flutter/material.dart';
// import 'dashboard.dart';  // Updated import path
// import 'profile_page.dart';  // Updated import path

// class MainScaffold extends StatefulWidget {
//   const MainScaffold({super.key});

//   @override
//   State<MainScaffold> createState() => _MainScaffoldState();
// }

// class _MainScaffoldState extends State<MainScaffold> {
//   int _selectedIndex = 0;

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   // Define the pages list here.
//   // We pass a function to the Dashboard so its SearchBar can trigger a page change.
//   // The ProfilePage does not need any parameters.
//   late final List<Widget> _pages = <Widget>[
//     Dashboard(onProfileTap: () => _onItemTapped(2)),
//     const Center(child: Text('Bookmarks Page')), // Placeholder for bookmarks
//     const ProfilePage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavBar(
//         selectedIndex: _selectedIndex,
//         onItemTapped: _onItemTapped,
//       ),
//     );
//   }
// }

// /// A shared, stateless Bottom Navigation Bar widget.
// /// It is controlled by the MainScaffold.
// class BottomNavBar extends StatelessWidget {
//   final int selectedIndex;
//   final void Function(int) onItemTapped;

//   const BottomNavBar({
//     super.key,
//     required this.selectedIndex,
//     required this.onItemTapped,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 88,
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 28),
//       decoration: const BoxDecoration(
//         color: Color(0xFF4A6FA5),
//         boxShadow: [
//           BoxShadow(
//             color: Color(0x3F000000),
//             blurRadius: 4,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           // Home Button
//           GestureDetector(
//             onTap: () => onItemTapped(0),
//             child: Icon(
//               Icons.home,
//               size: 30,
//               color: selectedIndex == 0 ? Colors.tealAccent[100] : Colors.white,
//             ),
//           ),
//           // Bookmarks Button
//           GestureDetector(
//             onTap: () => onItemTapped(1),
//             child: Icon(
//               Icons.bookmark,
//               size: 30,
//               color: selectedIndex == 1 ? Colors.tealAccent[100] : Colors.white,
//             ),
//           ),
//           // Profile Button
//           GestureDetector(
//             onTap: () => onItemTapped(2),
//             child: Icon(
//               Icons.account_circle,
//               size: 30,
//               color: selectedIndex == 2 ? Colors.tealAccent[100] : Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Dashboard extends StatelessWidget {
//   final VoidCallback? onProfileTap;

//   const Dashboard({Key? key, this.onProfileTap}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           const Text(
//             'Dashboard',
//             style: TextStyle(fontSize: 24),
//           ),
//           ElevatedButton(
//             onPressed: onProfileTap,
//             child: const Text('Go to Profile'),
//           ),
//         ],
//       ),
//     );
//   }
// }