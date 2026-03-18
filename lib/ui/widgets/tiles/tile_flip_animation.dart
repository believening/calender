import 'dart:math';
import 'package:flutter/material.dart';

/// 磁贴翻转动画控制器
///
/// 提供 3D 翻转效果，用于信息磁贴的正反面切换
class TileFlipController {
  late AnimationController animationController;
  late Animation<double> animation;
  
  /// 是否显示正面
  bool showFront = true;
  
  /// 初始化动画
  void init(TickerProvider vsync, {Duration duration = const Duration(milliseconds: 600)}) {
    animationController = AnimationController(
      vsync: vsync,
      duration: duration,
    );
    
    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  /// 翻转磁贴
  void flip() {
    if (animationController.status == AnimationStatus.dismissed ||
        animationController.status == AnimationStatus.completed) {
      showFront = !showFront;
      animationController.forward(from: 0).then((_) {
        animationController.reset();
      });
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
  
  const TileFlipAnimation({
    super.key,
    required this.front,
    required this.back,
    this.enableFlip = true,
    this.flipOnTap = true,
    this.onFlipComplete,
  });
  
  @override
  State<TileFlipAnimation> createState() => _TileFlipAnimationState();
}

class _TileFlipAnimationState extends State<TileFlipAnimation>
    with SingleTickerProviderStateMixin {
  late TileFlipController _controller;
  bool _showFront = true;
  
  @override
  void initState() {
    super.initState();
    _controller = TileFlipController();
    _controller.init(this);
    _controller.animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFlipComplete?.call();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleFlip() {
    if (!widget.enableFlip) return;
    
    setState(() {
      _showFront = !_showFront;
    });
    
    if (_showFront != _controller.showFront) {
      _controller.flip();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.flipOnTap ? _handleFlip : null,
      child: AnimatedBuilder(
        animation: _controller.animation,
        builder: (context, child) {
          final value = _controller.animation.value;
          final angle = value * pi;
          final isFront = value < 0.5;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 透视效果
              ..rotateY(angle),
            child: isFront
                ? widget.front
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: widget.back,
                  ),
          );
        },
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
