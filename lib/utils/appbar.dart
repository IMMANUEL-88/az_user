import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/sizes.dart';
import '../helper_functions.dart';
import 'device_utils.dart';

class EAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EAppBar(
      {super.key,
        this.title,
        this.showBackArrow = false,
        this.leadingIcon,
        this.actions,
        this.leadingOnPressed});

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    final dark = EHelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ESizes.md,
      ),
      child: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        automaticallyImplyLeading: false,
        leading: showBackArrow
            ? IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Iconsax.arrow_left,
              color: dark ? Colors.white : Colors.black,
            ))
            : leadingIcon != null
            ? IconButton(
          onPressed: leadingOnPressed,
          icon: Icon(leadingIcon),
        )
            : null,
        title: title,
        actions: actions,
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(EDeviceUtils.getAppBarHeight());
}