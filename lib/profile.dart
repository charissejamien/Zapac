import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 430,
      height: 932,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0xFFF9F9F9)),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 430,
              height: 345,
              decoration: BoxDecoration(color: const Color(0xFF4A6FA5)),
            ),
          ),
          Positioned(
            left: 0,
            top: 844,
            child: Container(
              width: 430,
              height: 88,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              decoration: BoxDecoration(
                color: Color(0xFF4A6FA5),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 142,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Stack(),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Stack(),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Stack(),
                      )
                    ]
                  )
                ]

              )
            )
          ),
          Positioned(
            left: 131,
            top: 84,
            child: Container(
              width: 174,
              height: 176,
              decoration: ShapeDecoration(
                color: const Color(0xFF6CA89A),
                shape: OvalBorder()),
            )
          ),
          Positioned(
            left: 248,
            top: 246,
            child: Container(
              width: 12,
              height: 11,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: Stack(),
            )
          ),
          Positioned(
            left: 87,
            top: 47,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
            ),
          ),
        ],
      )
    );
  }
}