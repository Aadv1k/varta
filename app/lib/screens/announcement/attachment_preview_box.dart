import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/models/announcement_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart' as path;

class AttachmentPreviewBox extends StatelessWidget {
  final AttachmentSelectionData attachment;
  VoidCallback? onDelete;
  VoidCallback? onPressed;
  final bool isPressable;
  final bool isCompact;

  AttachmentPreviewBox(
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

    switch (attachment.fileType) {
      case AnnouncementAttachmentFileType.DOC:
      case AnnouncementAttachmentFileType.DOCX:
        path = "assets/icons/file-doc.svg";
        break;
      case AnnouncementAttachmentFileType.PPT:
      case AnnouncementAttachmentFileType.PPTX:
        path = "assets/icons/file-ppt.svg";
        break;
      case AnnouncementAttachmentFileType.XLS:
      case AnnouncementAttachmentFileType.XLSX:
        path = "assets/icons/file-xls.svg";
        break;
      case AnnouncementAttachmentFileType.PDF:
        path = "assets/icons/file-pdf.svg";
        break;
      case AnnouncementAttachmentFileType.JPEG:
      case AnnouncementAttachmentFileType.PNG:
        return const Icon(Icons.photo_rounded,
            color: PaletteNeutral.shade400, size: IconSizes.iconLg);
      case AnnouncementAttachmentFileType.MP4:
      case AnnouncementAttachmentFileType.MOV:
      case AnnouncementAttachmentFileType.AVI:
        return SvgPicture.asset("assets/icons/video.svg",
            width: 28, height: 28);
    }

    return isCompact
        ? SvgPicture.asset(path, width: 26, height: 26)
        : SvgPicture.asset(path, width: 32, height: 32);
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: PaletteNeutral.shade030,
          ),
          height: 36,
          child: Row(
            children: [
              _getSvgIconFromFileType(),
              const SizedBox(width: Spacing.xs),
              Text(_truncateFileName(attachment.fileName),
                  maxLines: 1, style: Theme.of(context).textTheme.bodySmall)
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
