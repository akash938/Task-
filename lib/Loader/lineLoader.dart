import 'package:flutter/material.dart';

class GlowingLoader extends StatefulWidget {
  final Color glowColor;
  final double height;
  final double width;
  final Duration duration;

  const GlowingLoader({
    Key? key,
    this.glowColor = Colors.blue,
    this.height = 8.0,
    this.width = 150.0,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<GlowingLoader> createState() => _GlowingLoaderState();
}

class _GlowingLoaderState extends State<GlowingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(); 
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animatedGlow = Tween(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.height / 2),
            gradient: LinearGradient(
              colors: [
                widget.glowColor.withOpacity(0.0), 
                widget.glowColor.withOpacity(0.8), 
                widget.glowColor.withOpacity(0.0), 
              ],
              stops: [
                animatedGlow.value - 0.5,
                animatedGlow.value,
                animatedGlow.value + 0.5,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        );
      },
    );
  }
}