# Generated by Django 5.0.7 on 2024-11-13 04:08

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('attachments', '0006_attachment_announcement_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='attachment',
            name='file_size_in_bytes',
            field=models.IntegerField(default=1024),
            preserve_default=False,
        ),
        migrations.AlterField(
            model_name='attachment',
            name='file_type',
            field=models.CharField(choices=[('application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'MS Word Document'), ('application/msword', 'Document'), ('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'MS Excel Spreadsheet'), ('application/vnd.ms-excel', 'MS Excel Spreadsheet (older)'), ('application/vnd.openxmlformats-officedocument.presentationml.presentation', 'MS PowerPoint Presentation'), ('application/vnd.ms-powerpoint', 'MS PowerPoint Presentation (older)'), ('application/pdf', 'PDF Document'), ('image/jpeg', 'JPEG Image'), ('image/png', 'PNG Image'), ('video/mp4', 'MP4 Video'), ('video/x-msvideo', 'AVI Video'), ('video/quicktime', 'MOV Video'), ('text/plain', 'Plain Text')], max_length=76),
        ),
    ]