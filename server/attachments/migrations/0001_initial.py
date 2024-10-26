# Generated by Django 5.0.7 on 2024-10-26 09:03

import django.db.models.deletion
import uuid
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('accounts', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Attachment',
            fields=[
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('url', models.URLField(max_length=1024)),
                ('name', models.CharField(max_length=512)),
                ('type', models.CharField(choices=[('application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'MS Word Document'), ('application/msword', 'Document'), ('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'MS Excel Spreadsheet'), ('application/vnd.ms-excel', 'MS Excel Spreadsheet (older)'), ('application/vnd.openxmlformats-officedocument.presentationml.presentation', 'MS PowerPoint Presentation'), ('application/vnd.ms-powerpoint', 'MS PowerPoint Presentation (older)'), ('application/pdf', 'PDF Document'), ('image/jpeg', 'JPEG Image'), ('image/png', 'PNG Image'), ('video/mp4', 'MP4 Video'), ('video/x-msvideo', 'AVI Video'), ('video/quicktime', 'MOV Video')], max_length=76)),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='uploads', to='accounts.user')),
            ],
        ),
        migrations.CreateModel(
            name='AttachmentHash',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('hash', models.CharField(max_length=64, unique=True)),
                ('attachment', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='attachment_hash', to='attachments.attachment')),
            ],
            options={
                'indexes': [models.Index(fields=['hash'], name='attachments_hash_b55f14_idx')],
            },
        ),
    ]
