import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';

class TeacherCard extends StatelessWidget {
  const TeacherCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 260, maxWidth: 420),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PaletteNeutral.shade030,
            PaletteNeutral.shade050,
            PaletteNeutral.shade030,
          ],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: PaletteNeutral.shade100),
      ),
      child: Stack(
        children: [
          Positioned(
            top: Spacing.xs,
            right: Spacing.xs,
            child: Container(
              height: 240,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "10A",
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          height: 0.8,
                          fontWeight: FontWeight.w900,
                          color: PaletteNeutral.shade100.withOpacity(0.5),
                          fontSize: FontSize.text5xl * 2,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: Spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "CLASS TEACHER",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: AppColor.subheading,
                                  fontFamily: "GeistMono",
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5),
                        ),
                        Text(
                          "GEOGRAPHY",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  color: AppColor.body,
                                  fontFamily: "GeistMono",
                                  letterSpacing: 0.5),
                        ),
                        Text(
                          "ECONOMICS",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  color: AppColor.body,
                                  fontFamily: "GeistMono",
                                  letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
                left: Spacing.md, top: Spacing.md, right: Spacing.md),
            height: 240,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                        text: TextSpan(
                            text: "Varta",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    color: AppColor.heading,
                                    fontWeight: FontWeight.bold),
                            children: [
                          TextSpan(
                              text: " / Example School Name, Example City",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontFamily: "GeistMono",
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.heading,
                                  )),
                        ])),
                  ],
                ),
                const Spacer(),
                Text(
                  "Rajat\nSharma",
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: AppColor.heading,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        fontSize: FontSize.text3xl,
                      ),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  "PHONE +91 00000 00000",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontFamily: "GeistMono",
                        color: AppColor.body,
                        letterSpacing: 0.5,
                      ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "EMAIL JAMES.WEB@EXAMPLE.COM",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontFamily: "GeistMono",
                            color: AppColor.body,
                            letterSpacing: 0.5,
                          ),
                    ),
                    Text("TEACHER ID",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontFamily: "GeistMono",
                              color: AppColor.body,
                              letterSpacing: 0.5,
                            ))
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
