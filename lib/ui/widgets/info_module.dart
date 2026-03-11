import 'package:flutter/material.dart';
import '../../core/theme/calendar_theme.dart';
import '../../core/utils/responsive_helper.dart';

/// 可折叠的信息模块
///
/// 设计灵感：Notion 的模块化设计
/// - 清晰的模块边界
/// - 可折叠/展开
/// - 统一的视觉风格
class InfoModule extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget content;
  final CalendarTheme theme;
  final bool initiallyExpanded;

  const InfoModule({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.content,
    required this.theme,
    this.initiallyExpanded = true,
  });

  @override
  State<InfoModule> createState() => _InfoModuleState();
}

class _InfoModuleState extends State<InfoModule> with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.scale;

    return Container(
      margin: EdgeInsets.only(bottom: context.responsiveSpacing(16)),
      decoration: BoxDecoration(
        color: widget.theme.cardColor,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: widget.theme.textHint.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.iconColor.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 模块头部
          InkWell(
            onTap: _toggleExpand,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16 * scale)),
            child: Container(
              padding: EdgeInsets.all(context.responsiveSpacing(16)),
              child: Row(
                children: [
                  Container(
                    width: 36 * scale,
                    height: 36 * scale,
                    decoration: BoxDecoration(
                      color: widget.iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10 * scale),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 20 * scale,
                    ),
                  ),
                  SizedBox(width: 12 * scale),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(15),
                        fontWeight: FontWeight.w600,
                        color: widget.theme.textPrimary,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: _iconTurns,
                    child: Icon(
                      Icons.expand_more,
                      color: widget.theme.textHint,
                      size: 20 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 模块内容
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Container(
              padding: EdgeInsets.fromLTRB(
                context.responsiveSpacing(16),
                0,
                context.responsiveSpacing(16),
                context.responsiveSpacing(16),
              ),
              child: widget.content,
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeOutCubic,
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}
