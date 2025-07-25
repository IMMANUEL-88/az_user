import 'package:flutter/material.dart';
import '../helper_functions.dart';

class EAnimationLoaderWidget extends StatelessWidget {
  final String text;
  final String image;

  const EAnimationLoaderWidget({
    super.key,
    required this.image,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final dark = EHelperFunctions.isDarkMode(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(image),
        const SizedBox(height: 20),
        Text(
          text,
          style: Theme.of(context).textTheme.labelLarge!.apply(
            color: dark ? Colors.white : Colors.black,

          ),
        ),
      ],
    );
  }
}