import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduway/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();

    return AppBar(
      title: Text(title),
      centerTitle: false,
      backgroundColor: backgroundColor ?? AppColors.bgCard,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: (showBackButton && canPop)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => context.pop(),
            )
          : null,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.border.withOpacity(0.5),
          height: 1,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
