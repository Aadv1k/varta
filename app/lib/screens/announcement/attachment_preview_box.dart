import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/models/announcement_model.dart';
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
      this.isPressable = false,
      this.isCompact = false,
      this.onPressed});

  String _truncateFileName(String fileName) {
    if (fileName.length <= 28) {
      return fileName;
    }

    String body = path.withoutExtension(fileName);
    String ext = path.extension(fileName);

    return "${body.substring(0, 12).trim()}...${body.substring(body.length - 12, body.length).trim()}$ext";
  }

  Widget _getSvgIconFromFileType() {
    String path;
    double size = isCompact ? 26 : 32;

    switch (attachment.fileType) {
      case AnnouncementAttachmentFileType.doc:
      case AnnouncementAttachmentFileType.docx:
        path = "assets/icons/file-doc.svg";
        break;
      case AnnouncementAttachmentFileType.ppt:
      case AnnouncementAttachmentFileType.pptx:
        path = "assets/icons/file-ppt.svg";
        break;
      case AnnouncementAttachmentFileType.xls:
      case AnnouncementAttachmentFileType.xlsx:
        path = "assets/icons/file-xls.svg";
        break;
      case AnnouncementAttachmentFileType.pdf:
        path = "assets/icons/file-pdf.svg";
      case AnnouncementAttachmentFileType.jpeg:
      case AnnouncementAttachmentFileType.png:
        path = "assets/icons/image.svg";
        size = isCompact ? 22 : 24;
      case AnnouncementAttachmentFileType.mp4:
      case AnnouncementAttachmentFileType.mov:
      case AnnouncementAttachmentFileType.avi:
        path = "assets/icons/video.svg";
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
              _getSvgIconFromFileType(),
              const SizedBox(width: Spacing.sm),
              Text(_truncateFileName(attachment.fileName),
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
        onTap: onPressed,
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
                  child: _getSvgIconFromFileType()),
              const SizedBox(height: Spacing.xs),
              Text(_truncateFileName(attachment.fileName),
                  maxLines: 2, style: Theme.of(context).textTheme.bodySmall)
            ],
          ),
        ),
      ),
      if (onDelete != null)
        Positioned(
          right: -18,
          top: -18,
          child: IconButton.filled(
              style: const ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(PaletteNeutral.shade200)),
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.close,
                  color: AppColor.activeChipFg, size: IconSizes.iconSm)),
        ),
    ]);
  }
}
