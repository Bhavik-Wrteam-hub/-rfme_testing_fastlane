import 'dart:async';
import 'dart:math' as math;


import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';

class CustomPremiumButton extends StatefulWidget {
  const CustomPremiumButton({
    required this.premiumPropertyCount,
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;
  final int premiumPropertyCount;

  @override
  State<CustomPremiumButton> createState() => _CustomPremiumButtonState();
}

class _CustomPremiumButtonState extends State<CustomPremiumButton>
    with TickerProviderStateMixin {
  // Separate animation controllers
  late AnimationController _borderAnimationController;
  late AnimationController _iconAnimationController;
  late AnimationController _textAnimationController;

  // Separate animations
  late Animation<double> _iconSlideAnimation;
  late Animation<double> _textSlideAnimation;

  // Define your two icons and texts here
  final List<String> _icons = [
    AppIcons.premium, // First icon
    AppIcons.properties, // Second icon
  ];

  final List<String> _texts = [
    'goPremium', // First text
    'properties', // Second text
  ];

  // Track current indices
  int _currentIconIndex = 0;
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();

    // Border animation - continuous rotation every 5 seconds
    _borderAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    unawaited(_borderAnimationController.repeat());

    // Icon animation - switches every 3 seconds
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600), // Transition duration
      vsync: this,
    );

    // Text animation - switches every 3 seconds (offset by 1.5s from icon)
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600), // Transition duration
      vsync: this,
    );

    // Define the slide animations
    _iconSlideAnimation =
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _iconAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    _textSlideAnimation =
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _textAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    // Start the periodic animations
    _startPeriodicAnimations();
  }

  void _startPeriodicAnimations() {
    // Icon animation every 3 seconds
    Future.delayed(Duration.zero, _animateIcon);

    Future.delayed(Duration.zero, _animateText);
  }

  Future<void> _animateIcon() async {
    if (!mounted) return;

    await _iconAnimationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _currentIconIndex = (_currentIconIndex + 1) % _icons.length;
        });
        _iconAnimationController.reset();

        // Schedule next animation
        Future.delayed(const Duration(milliseconds: 2400), _animateIcon);
      }
    });
  }

  Future<void> _animateText() async {
    if (!mounted) return;

    await _textAnimationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _texts.length;
        });
        _textAnimationController.reset();

        // Schedule next animation
        Future.delayed(const Duration(milliseconds: 2400), _animateText);
      }
    });
  }

  @override
  void dispose() {
    _borderAnimationController.dispose();
    _iconAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed != () {} ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _borderAnimationController,
          _iconAnimationController,
          _textAnimationController,
        ]),
        builder: (context, child) {
          return CustomPaint(
            painter: GradientBorderPainter(
              context: context,
              animation: _borderAnimationController.value,
              borderWidth: 1,
              borderRadius: 8,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.color.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),

              child: Row(
                children: [
                  // Animated Icon Container
                  SizedBox(
                    width: 20.rw(context),
                    height: 20.rh(context),
                    child: ClipRect(
                      child: Stack(
                        children: [
                          // Current icon
                          Transform.translate(
                            offset: Offset(
                              0,
                              -_iconSlideAnimation.value * 20.rh(context),
                            ),
                            child: Opacity(
                              opacity: 1.0 - _iconSlideAnimation.value,
                              child: CustomImage(
                                imageUrl: _icons[_currentIconIndex],
                                color: _currentIconIndex > 0
                                    ? context.color.tertiaryColor
                                    : null,
                                width: 20.rw(context),
                                height: 20.rh(context),
                              ),
                            ),
                          ),
                          // Next icon (sliding in from top)
                          Transform.translate(
                            offset: Offset(
                              0,
                              (1.0 - _iconSlideAnimation.value) *
                                  20.rh(context),
                            ),
                            child: Opacity(
                              opacity: _iconSlideAnimation.value,
                              child: CustomImage(
                                imageUrl:
                                    _icons[(_currentIconIndex + 1) %
                                        _icons.length],
                                color:
                                    (_currentIconIndex + 1) % _icons.length > 0
                                    ? context.color.tertiaryColor
                                    : null,
                                width: 20.rw(context),
                                height: 20.rh(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Animated Text Container
                  ClipRect(
                    child: Stack(
                      children: [
                        // Current text
                        Transform.translate(
                          offset: Offset(
                            0,
                            _textSlideAnimation.value * 20,
                          ),
                          child: Opacity(
                            opacity: 1.0 - _textSlideAnimation.value,
                            child: CustomText(
                              _currentTextIndex > 0
                                  ? '${widget.premiumPropertyCount} ${_texts[_currentTextIndex].translate(context)}'
                                  : _texts[_currentTextIndex].translate(
                                      context,
                                    ),
                              color: context.color.textColorDark,
                              fontWeight: .w500,
                              fontSize: context.font.xs,
                            ),
                          ),
                        ),
                        // Next text (sliding in from bottom)
                        Transform.translate(
                          offset: Offset(
                            0,
                            (_textSlideAnimation.value - 1.0) * 20,
                          ),
                          child: Opacity(
                            opacity: _textSlideAnimation.value,
                            child: CustomText(
                              (_currentTextIndex + 1) % _texts.length > 0
                                  ? '${widget.premiumPropertyCount} ${_texts[(_currentTextIndex + 1) % _texts.length].translate(context)}'
                                  : _texts[(_currentTextIndex + 1) %
                                            _texts.length]
                                        .translate(context),
                              color: context.color.textColorDark,
                              fontWeight: .w500,
                              fontSize: context.font.xs,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class GradientBorderPainter extends CustomPainter {
  GradientBorderPainter({
    required this.animation,
    required this.borderWidth,
    required this.borderRadius,
    required this.context,
  });

  final double animation; // Animation value from 0.0 to 1.0
  final double borderWidth; // Thickness of the border stroke
  final double borderRadius; // Corner radius for rounded rectangle
  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // ROTATION CALCULATION:
    // Convert animation value (0-1) to full rotation (0 to 2π radians)
    // This creates the spinning effect around the button's perimeter
    final rotationAngle = animation * 2 * math.pi;

    // DIAGONAL GRADIENT SETUP:
    // Instead of rotating around center, we create a diagonal gradient
    // that moves from bottom-left to top-right corners

    // Base diagonal angle: -45 degrees (bottom-left to top-right)
    // Convert to radians: -45° = -π/4 radians
    const baseDiagonalAngle = -math.pi / 4;

    // Add rotation to the base diagonal angle
    final totalAngle = baseDiagonalAngle + rotationAngle;

    final center = Offset(size.width / 2, size.height / 2);

    // Use diagonal length as radius to ensure gradient covers entire button
    // This is longer than width or height alone, ensuring full coverage
    final diagonalLength = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    final radius = diagonalLength / 2;

    // GRADIENT START/END POINTS:
    // Calculate points along the rotating diagonal line
    final startPoint = Offset(
      center.dx + math.cos(totalAngle) * radius,
      center.dy + math.sin(totalAngle) * radius,
    );

    final endPoint = Offset(
      center.dx - math.cos(totalAngle) * radius,
      center.dy - math.sin(totalAngle) * radius,
    );

    // GRADIENT COLOR CONFIGURATION:
    // This array defines how colors transition along the gradient line
    // Position in array = position along gradient (0% to 100%)
    final gradient = LinearGradient(
      begin: Alignment(
        (startPoint.dx - center.dx) / radius,
        (startPoint.dy - center.dy) / radius,
      ),
      end: Alignment(
        (endPoint.dx - center.dx) / radius,
        (endPoint.dy - center.dy) / radius,
      ),
      colors: [
        context.color.tertiaryColor.withValues(alpha: 0.2),
        context.color.tertiaryColor.withValues(alpha: 0.7),
        context.color.tertiaryColor,
        context.color.tertiaryColor.withValues(alpha: 0.7),
        context.color.tertiaryColor.withValues(alpha: 0.5),
        context.color.tertiaryColor.withValues(alpha: 0.2),
      ],
    );



    // PAINT CONFIGURATION:
    final paint = Paint()
      ..shader = gradient
          .createShader(rect) // Apply the gradient
      ..style = .stroke // Draw only the border, not fill
      ..strokeWidth = borderWidth; // Set border thickness

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant GradientBorderPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
