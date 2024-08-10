import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        color: AppColors.primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Varta", style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: Spacing.md)
                SizedBox(
                  width: 300,
                  child: Text("Stay on top of what's happening in your school", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.darkBody))),
              ],
            ),
            const SizedBox(),
          ],
        )
      ),
    );
  }
}