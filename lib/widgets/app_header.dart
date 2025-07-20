import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    this.title,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: showBackButton ? null : Container(),
      automaticallyImplyLeading: showBackButton,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo Soutra AI
          Container(
            width: 32,
            height: 32,
            child: Image.asset(
              'assets/images/logo_app.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.psychology,
                  size: 32,
                  color: Colors.white,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Soutra AI',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (title != null) ...[
            const SizedBox(width: 16),
            Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
