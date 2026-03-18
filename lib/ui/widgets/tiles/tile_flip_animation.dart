import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 翻转方向
enum FlipDirection {
  horizontal,  // 水平翻转（绕Y轴）
  vertical,    // 垂直翻转（绕X轴）
}

/// 磁贴翻转动画控制器
///
/// 提供 3D 翻转效果，用于信息磁贴的正反面切换
class TileFlipController {
  late AnimationController animationController;
  late Animation<double> animation;

  /// 是否显示正面
  bool showFront = true;

  /// 翻转方向
  FlipDirection direction = FlipDirection.horizontal;

  /// 初始化动画
  void init(TickerProvider vsync, {
    Duration duration = const Duration(milliseconds: 600),
    FlipDirection flipDirection = FlipDirection.horizontal,
  }) {
    direction = flipDirection;
    animationController = AnimationController(
      vsync: vsync,
      duration: duration,
    );

    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  /// 翻转磁贴
  void flip() {
    if (animationController.status == AnimationStatus.dismissed ||
        animationController.status == AnimationStatus.completed) {
      showFront = !showFront;
      if (showFront) {
        animationController.reverse();
      } else {
        animationController.forward();
      }
    }
  }

  /// 翻转到正面
  void flipToFront() {
    if (!showFront) {
      flip();
    }
  }

  /// 翻转到背面
  void flipToBack() {
    if (showFront) {
      flip();
    }
  }

  /// 释放资源
  void dispose() {
    animationController.dispose();
  }
}

/// 磁贴翻转动画 Widget
class TileFlipAnimation extends StatefulWidget {
  /// 正面内容
  final Widget front;

  /// 背面内容
  final Widget back;

  /// 是否启用翻转
  final bool enableFlip;

  /// 点击时是否自动翻转
  final bool flipOnTap;

  /// 翻转完成回调
  final VoidCallback? onFlipComplete;

  /// 翻转方向
  final FlipDirection direction;

  /// 透视强度
  final double perspective;

  /// 翻转持续时间
  final Duration duration;

  const TileFlipAnimation({
    super.key,
    required this.front,
    required this.back,
    this.enableFlip = true,
    this.flipOnTap = true,
    this.onFlipComplete,
    this.direction = FlipDirection.horizontal,
    this.perspective = 0.002,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<TileFlipAnimation> createState() => _TileFlipAnimationState();
}

class _TileFlipAnimationState extends State<TileFlipAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleFlip() {
    if (!widget.enableFlip) return;

    HapticFeedback.lightImpact();
    setState(() {
      _showFront = !_showFront;
    });

    if (_showFront) {
      _controller.reverse().then((_) {
        widget.onFlipComplete?.call();
      });
    } else {
      _controller.forward().then((_) {
        widget.onFlipComplete?.call();
      });
    }
  }

  Matrix4 _buildTransform(double value) {
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, widget.perspective); // 透视效果

    final angle = value * math.pi;

    if (widget.direction == FlipDirection.horizontal) {
      matrix.rotateY(angle);
    } else {
      matrix.rotateX(angle);
    }

    return matrix;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.flipOnTap ? _handleFlip : null,
        onLongPress: widget.enableFlip ? _handleFlip : null,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final value = _animation.value;
              final isFront = value < 0.5;

              return Transform(
                alignment: Alignment.center,
                transform: _buildTransform(value),
                child: isFront
                    ? widget.front
                    : Transform(
                        alignment: Alignment.center,
                        transform: widget.direction == FlipDirection.horizontal
                            ? (Matrix4.identity()..rotateY(math.pi))
                            : (Matrix4.identity()..rotateX(math.pi)),
                        child: widget.back,
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 简化版翻转磁贴
///
/// 使用 AnimatedSwitcher 实现简单的翻转效果
class SimpleFlipTile extends StatefulWidget {
  /// 正面内容
  final Widget front;

  /// 背面内容
  final Widget back;

  /// 翻转持续时间
  final Duration duration;

  /// 是否启用点击翻转
  final bool flipOnTap;

  const SimpleFlipTile({
    super.key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 400),
    this.flipOnTap = true,
  });

  @override
  State<SimpleFlipTile> createState() => _SimpleFlipTileState();
}

class _SimpleFlipTileState extends State<SimpleFlipTile> {
  bool _showFront = true;

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.flipOnTap ? _toggle : null,
      child: AnimatedSwitcher(
        duration: widget.duration,
        transitionBuilder: (child, animation) {
          return AnimatedRotation(
            duration: widget.duration,
            turns: animation.value * 0.5,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: _showFront
            ? KeyedSubtree(
                key: const ValueKey('front'),
                child: widget.front,
              )
            : KeyedSubtree(
                key: const ValueKey('back'),
                child: widget.back,
              ),
      ),
    );
  }
}

/// 高级 3D 翻转动画组件
class FlipAnimation3D extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool isFlipped;
  final Duration duration;
  final FlipDirection direction;
  final VoidCallback? onFlipComplete;
  final double perspective;

  const FlipAnimation3D({
    super.key,
    required this.front,
    required this.back,
    this.isFlipped = false,
    this.duration = const Duration(milliseconds: 600),
    this.direction = FlipDirection.horizontal,
    this.onFlipComplete,
    this.perspective = 0.002,
  });

  @override
  State<FlipAnimation3D> createState() => _FlipAnimation3DState();
}

class _FlipAnimation3DState extends State<FlipAnimation3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    if (widget.isFlipped) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FlipAnimation3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward().then((_) {
          widget.onFlipComplete?.call();
        });
      } else {
        _controller.reverse().then((_) {
          widget.onFlipComplete?.call();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Matrix4 _buildTransform(double value) {
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, widget.perspective); // 透视效果

    if (widget.direction == FlipDirection.horizontal) {
      matrix.rotateY(value * math.pi);
    } else {
      matrix.rotateX(value * math.pi);
    }

    return matrix;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;

        // 在中间点切换显示的内容
        final showFront = value < 0.5;

        Widget currentChild;
        if (showFront) {
          currentChild = widget.front;
        } else {
          // 反向显示背面
          currentChild = Transform(
            transform: widget.direction == FlipDirection.horizontal
                ? (Matrix4.identity()..rotateY(math.pi))
                : (Matrix4.identity()..rotateX(math.pi)),
            alignment: Alignment.center,
            child: widget.back,
          );
        }

        return Transform(
          transform: _buildTransform(value),
          alignment: Alignment.center,
          child: currentChild,
        );
      },
    );
  }
}

/// 缩放动画组件
class ScaleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double beginScale;
  final double endScale;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOutBack,
    this.beginScale = 0.95,
    this.endScale = 1.0,
  });

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// 渐变入场动画
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.offset = const Offset(0, 0.1),
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// 翻转磁贴包装器
class FlippableTile extends StatefulWidget {
  final Widget front;
  final Widget? back;
  final String? explanation;
  final String? title;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool enableFlip;
  final VoidCallback? onTap;
  final Duration flipDuration;

  const FlippableTile({
    super.key,
    required this.front,
    this.back,
    this.explanation,
    this.title,
    required this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.enableFlip = true,
    this.onTap,
    this.flipDuration = const Duration(milliseconds: 600),
  });

  @override
  State<FlippableTile> createState() => _FlippableTileState();
}

class _FlippableTileState extends State<FlippableTile> {
  bool _isFlipped = false;
  bool _isHovered = false;

  void _toggleFlip() {
    if (!widget.enableFlip) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasBack = widget.back != null || widget.explanation != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap ?? (hasBack ? _toggleFlip : null),
        onLongPress: widget.enableFlip && hasBack ? _toggleFlip : null,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: hasBack
              ? FlipAnimation3D(
                  front: _buildFrontContainer(),
                  back: widget.back ?? _buildExplanationBack(),
                  isFlipped: _isFlipped,
                  duration: widget.flipDuration,
                )
              : _buildFrontContainer(),
        ),
      ),
    );
  }

  Widget _buildFrontContainer() {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: _isHovered
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.front,
    );
  }

  Widget _buildExplanationBack() {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              widget.title ?? '释义',
              style: TextStyle(
                color: widget.foregroundColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // 释义内容
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.explanation ?? '',
                  style: TextStyle(
                    color: widget.foregroundColor.withOpacity(0.9),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            // 提示
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '点击返回',
                style: TextStyle(
                  color: widget.foregroundColor.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
