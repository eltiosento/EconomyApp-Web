import 'package:flutter/material.dart';

class ButtonsAppBar extends StatefulWidget {
  const ButtonsAppBar(this.title, {super.key, this.onTap});
  final String title;
  final VoidCallback? onTap;

  @override
  ButtonsAppBarState createState() => ButtonsAppBarState();
}

class ButtonsAppBarState extends State<ButtonsAppBar> {
  late bool _isHovering;

  @override
  void initState() {
    super.initState();
    _isHovering = false;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (value) {
        setState(() {
          _isHovering = value;
        });
      },
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: _isHovering ? Colors.white : Colors.white70,
              fontFamily: 'Montserrat',
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
