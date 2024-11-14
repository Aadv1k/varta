import 'package:app/models/user_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';

class TeacherCard extends StatelessWidget {
  final UserModel user;
  const TeacherCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TeacherDetails userDetails = user.details as TeacherDetails;

    String? primaryEmail = user.contacts
        .firstWhereOrNull((contact) => contact.contactType == ContactType.email)
        ?.contactData;

    String? primaryPhoneNumber = user.contacts
        .firstWhereOrNull(
            (contact) => contact.contactType == ContactType.phoneNumber)
        ?.contactData;

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
                  userDetails.classTeacherOf != null
                      ? Text(
                          userDetails.classTeacherOf.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                height: 0.8,
                                fontWeight: FontWeight.w900,
                                color: PaletteNeutral.shade100.withOpacity(0.5),
                                fontSize: FontSize.text5xl * 2,
                              ),
                        )
                      : const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: Spacing.md, right: Spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          userDetails.classTeacherOf != null
                              ? "CLASS TEACHER"
                              : "SUBJECT TEACHER",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: AppColor.subheading,
                                  fontFamily: "GeistMono",
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5),
                        ),
                        ...userDetails.departments.map(
                          (department) => Text(
                            department.deptName.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: AppColor.body,
                                    fontFamily: "GeistMono",
                                    letterSpacing: 0.5),
                          ),
                        )
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
                              text: " / ${user.school.schoolName}",
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
                  "${user.firstName}\n${user.lastName.isEmpty ? (user.middleName != null ? "${user.middleName}." : "") : user.lastName}",
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: AppColor.heading,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        fontSize: FontSize.text3xl,
                      ),
                ),
                const SizedBox(height: Spacing.md),
                if (primaryPhoneNumber != null)
                  Text(
                    "PHONE $primaryPhoneNumber",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontFamily: "GeistMono",
                          color: AppColor.body,
                          letterSpacing: 0.5,
                        ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (primaryEmail != null)
                      Text(
                        "EMAIL $primaryEmail",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontFamily: "GeistMono",
                              color: AppColor.body,
                              letterSpacing: 0.5,
                            ),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    const Spacer(),
                    Text(
                      "TEACHER ID",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontFamily: "GeistMono",
                            color: AppColor.body,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
