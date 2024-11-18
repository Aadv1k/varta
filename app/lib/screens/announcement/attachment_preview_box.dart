import 'dart:html' as html;

import 'package:app/common/colors.dart';
import 'package:app/common/exceptions.dart';
import 'package:app/common/sizes.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/repository/announcements_repo.dart';
import 'package:app/widgets/error_snackbar.dart';
import 'package:app/widgets/generic_error_box.dart';
import 'package:app/widgets/varta_app_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart' as path;

class AttachmentPreviewBox extends StatelessWidget {
  final AttachmentSelectionData attachment;
  final VoidCallback? onDelete;
  final VoidCallback? onPressed;
  final bool isPressable;
  final bool isCompact;

  const AttachmentPreviewBox(
      {super.key,
      required this.attachment,
      this.onDelete,
      this.isPressable = true,
      this.isCompact = false,
      this.onPressed});

  static String truncateFileName(String fileName) {
    if (fileName.length <= 28) {
      return fileName;
    }

    String body = path.withoutExtension(fileName);
    String ext = path.extension(fileName);

    return "${body.substring(0, 12).trim()}...${body.substring(body.length - 12, body.length).trim()}$ext";
  }

  static String getSvgFileFromFileType(
      AnnouncementAttachmentFileType fileType) {
    switch (fileType) {
      case AnnouncementAttachmentFileType.doc:
      case AnnouncementAttachmentFileType.docx:
        return "assets/icons/file-doc.svg";
      case AnnouncementAttachmentFileType.ppt:
      case AnnouncementAttachmentFileType.pptx:
        return "assets/icons/file-ppt.svg";
      case AnnouncementAttachmentFileType.xls:
      case AnnouncementAttachmentFileType.xlsx:
        return "assets/icons/file-xls.svg";
      case AnnouncementAttachmentFileType.pdf:
        return "assets/icons/file-pdf.svg";
      case AnnouncementAttachmentFileType.jpeg:
      case AnnouncementAttachmentFileType.png:
        return "assets/icons/image.svg";
      case AnnouncementAttachmentFileType.mp4:
      case AnnouncementAttachmentFileType.mov:
      case AnnouncementAttachmentFileType.avi:
        return "assets/icons/video.svg";
    }
  }

  Widget getSvgIconFromFileType() {
    String path =
        AttachmentPreviewBox.getSvgFileFromFileType(attachment.fileType);
    double size = isCompact ? 26 : 32;

    switch (attachment.fileType) {
      case AnnouncementAttachmentFileType.doc:
      case AnnouncementAttachmentFileType.docx:
      case AnnouncementAttachmentFileType.ppt:
      case AnnouncementAttachmentFileType.pptx:
      case AnnouncementAttachmentFileType.xls:
      case AnnouncementAttachmentFileType.xlsx:
      case AnnouncementAttachmentFileType.pdf:
        break;
      case AnnouncementAttachmentFileType.jpeg:
      case AnnouncementAttachmentFileType.png:
        size = isCompact ? 22 : 24;
      case AnnouncementAttachmentFileType.mp4:
      case AnnouncementAttachmentFileType.mov:
      case AnnouncementAttachmentFileType.avi:
        size = isCompact ? 22 : 24;
    }

    return SvgPicture.asset(path, width: size, height: size);
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm, vertical: Spacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: PaletteNeutral.shade030,
          ),
          child: Row(
            children: [
              getSvgIconFromFileType(),
              const SizedBox(width: Spacing.sm),
              Text(truncateFileName(attachment.fileName),
                  maxLines: 1,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColor.body))
            ],
          ));
    }
    return Stack(clipBehavior: Clip.none, children: [
      GestureDetector(
        onTap: isPressable
            ? () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AttachmentPreviewScreen(
                              attachment: attachment,
                            )));
                onPressed?.call();
              }
            : null,
        child: Container(
          height: 100,
          width: 120,
          padding: const EdgeInsets.only(left: Spacing.xs, right: Spacing.xs),
          decoration: BoxDecoration(
              color: PaletteNeutral.shade030,
              border: Border.all(color: PaletteNeutral.shade040),
              borderRadius: const BorderRadius.all(Radius.circular(8))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: Spacing.xs),
                  child: getSvgIconFromFileType()),
              const SizedBox(height: Spacing.xs),
              Text(truncateFileName(attachment.fileName),
                  maxLines: 2, style: Theme.of(context).textTheme.bodySmall)
            ],
          ),
        ),
      ),
      if (onDelete != null)
        Positioned(
          right: Spacing.xs,
          top: Spacing.xs,
          child: IconButton(
              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.close,
                  color: PaletteNeutral.shade600, size: 22)),
        ),
    ]);
  }
}

class AttachmentPreviewScreen extends StatelessWidget {
  final AttachmentSelectionData attachment;
  final AnnouncementsRepository _announcementsRepository =
      AnnouncementsRepository();
  late final Future<String> _attachmentUrlFuture;

  AttachmentPreviewScreen({super.key, required this.attachment}) {
    _attachmentUrlFuture =
        _announcementsRepository.getPresignedAttachmentUrl(attachment.id!);
  }

  @override
  Widget build(BuildContext context) {
    bool isImage = {
      AnnouncementAttachmentFileType.jpeg,
      AnnouncementAttachmentFileType.png
    }.contains(attachment.fileType);

    return Scaffold(
      backgroundColor: AppColor.primaryBg,
      appBar: VartaAppBar(
        actions: [
          FutureBuilder<String>(
            future: _attachmentUrlFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  width: IconSizes.iconMd,
                  height: IconSizes.iconMd,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const SizedBox.shrink();
              }

              return IconButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  try {
                    if (kIsWeb) {
                      final element = html.AnchorElement(href: snapshot.data);
                      element.download = snapshot.data;
                      element.click();
                    } else {
                      final attachmentBlob = await _announcementsRepository
                          .downloadAttachment(snapshot.data!);

                      await FilePicker.platform.saveFile(
                        fileName: attachment.fileName,
                        type: FileType.image,
                        bytes: attachmentBlob,
                      );
                    }
                  } catch (exc) {
                    print(exc);
                    if (context.mounted) {
                      VartaSnackbar(
                        innerText: exc is ApiException
                            ? "Failed to download attachment"
                            : "Unable to save the file",
                        snackBarVariant: VartaSnackBarVariant.error,
                      ).show(context);
                    }
                  }
                },
                icon: const Icon(Icons.download, size: IconSizes.iconMd),
                color: AppColor.subtitle,
              );
            },
          ),
        ],
        centerTitle: false,
        title: AttachmentPreviewBox.truncateFileName(attachment.fileName),
      ),
      body: Center(
          child: FutureBuilder<String>(
        future: _attachmentUrlFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return GenericErrorBox(
              size: ErrorSize.medium,
              errorMessage:
                  "Couldn't load the attachment: ${snapshot.error.toString()}",
            );
          }

          return isImage
              ? SizedBox(
                  height: double.infinity,
                  child: InteractiveViewer(
                    child: Image.network(
                      snapshot.data!,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: GenericErrorBox(
                          size: ErrorSize.medium,
                          errorMessage: "Couldn't load the image",
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) =>
                          loadingProgress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator()),
                    ),
                  ),
                )
              : Opacity(
                  opacity: 0.25,
                  child: SvgPicture.asset(
                    AttachmentPreviewBox.getSvgFileFromFileType(
                        attachment.fileType),
                  ),
                );
        },
      )),
    );
  }
}
