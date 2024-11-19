import 'package:app/repository/announcements_repo.dart';
import 'package:file_picker/file_picker.dart';

Future<void> download(String url, String fileName) async {
  final attachmentBlob =
      await AnnouncementsRepository().downloadAttachment(url);

  await FilePicker.platform.saveFile(
    fileName: fileName,
    type: FileType.any,
    bytes: attachmentBlob,
  );
}
