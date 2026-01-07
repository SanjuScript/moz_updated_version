import 'dart:developer';
import 'package:flutter/material.dart';

class MozSlider extends StatefulWidget {
  final Duration currentPosition;
  final Duration totalDuration;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final Color sliderColor;
  final Color thumbColor;
  final Color backgroundColor;

  const MozSlider({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.onChanged,
    this.onChangeEnd,
    this.sliderColor = Colors.blue,
    this.thumbColor = Colors.white,
    this.backgroundColor = Colors.grey,
  });

  @override
  _MozSliderState createState() => _MozSliderState();
}

class _MozSliderState extends State<MozSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _trackHeightAnimation;
  double? _dragValue;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _trackHeightAnimation = Tween<double>(
      begin: 9.0,
      end: 13.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  double get _currentSliderValue {
    if (_isDragging && _dragValue != null) {
      return _dragValue!;
    }

    if (widget.totalDuration.inMilliseconds <= 0) return 0.0;

    final value =
        widget.currentPosition.inMilliseconds /
        widget.totalDuration.inMilliseconds;

    return value.clamp(0.0, 1.0);
  }

  Duration get _displayPosition {
    if (_isDragging && _dragValue != null) {
      return Duration(
        milliseconds: (widget.totalDuration.inMilliseconds * _dragValue!)
            .toInt(),
      );
    }
    return widget.currentPosition;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bool isDesktop = size.width > 900;
    return Column(
      children: [
        AnimatedBuilder(
          animation: _trackHeightAnimation,
          builder: (context, child) {
            return Container(
              width: size.width,
              height: size.height * .038,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: widget.sliderColor,
                  inactiveTrackColor: widget.backgroundColor,
                  thumbColor: widget.thumbColor,
                  trackShape: const RoundedRectSliderTrackShape(),
                  trackHeight: _trackHeightAnimation.value,
                  overlayColor: widget.thumbColor.withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 0,
                  ),
                ),
                child: Slider(
                  value: _currentSliderValue,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    setState(() {
                      _dragValue = value;
                    });
                  },
                  onChangeStart: (value) {
                    _startDrag(value);
                  },
                  onChangeEnd: (value) {
                    _stopDrag(value);
                  },
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_displayPosition),
                style: TextStyle(
                  fontSize: isDesktop ? size.width * 0.01 : size.width * .03,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xff97A4B7),
                ),
              ),
              Text(
                _formatDuration(widget.totalDuration),
                style: TextStyle(
                  fontSize: isDesktop ? size.width * 0.01 : size.width * .03,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xff97A4B7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _startDrag(double value) {
    setState(() {
      _isDragging = true;
      _dragValue = value;
    });
    _controller.forward();
  }

  void _stopDrag(double value) {
    setState(() {
      _isDragging = false;
    });
    _controller.reverse();

    widget.onChanged(value);
    if (widget.onChangeEnd != null) {
      widget.onChangeEnd!(value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
