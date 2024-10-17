import 'package:app/models/user_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';

class StudentCard extends StatelessWidget {
  final UserModel user;

  const StudentCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StudentDetails userDetail = user.details as StudentDetails;

    var primaryPhoneNumber = user.contacts.firstWhereOrNull(
        (contact) => contact.contactType == ContactType.phoneNumber);

    var primaryEmail = user.contacts.firstWhereOrNull(
        (contact) => contact.contactType == ContactType.email);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 260, maxWidth: 420),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primaryColor,
            AppColor.primaryColor.withOpacity(0.85),
            AppColor.primaryColor,
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
                    userDetail.classroom?.toString() ?? "N/A",
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          height: 0.8,
                          fontWeight: FontWeight.w900,
                          color: PaletteNeutral.shade000.withOpacity(0.2),
                          fontSize: FontSize.text5xl * 2,
                        ),
                  ),
                  const Spacer(),
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
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: PaletteNeutral.shade000,
                                  fontWeight: FontWeight.bold,
                                ),
                        children: [
                          TextSpan(
                            text: " / ${user.school.schoolName}",
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      fontFamily: "GeistMono",
                                      fontWeight: FontWeight.w500,
                                      color: PaletteNeutral.shade040,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  "${user.firstName}\n${user.lastName}",
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        fontSize: FontSize.text3xl,
                      ),
                ),
                const SizedBox(height: Spacing.md),
                if (primaryPhoneNumber != null)
                  Text(
                    "PHONE ${primaryPhoneNumber.contactData}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontFamily: "GeistMono",
                          color: PaletteNeutral.shade040,
                          letterSpacing: 0.5,
                        ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (primaryEmail != null)
                      Text(
                        "EMAIL ${primaryEmail.contactData}",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontFamily: "GeistMono",
                              color: PaletteNeutral.shade040,
                              letterSpacing: 0.5,
                            ),
                      ),
                    const Spacer(),
                    Text(
                      "STUDENT ID",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontFamily: "GeistMono",
                            color: PaletteNeutral.shade040,
                            letterSpacing: 0.5,
                          ),
                    ),
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
