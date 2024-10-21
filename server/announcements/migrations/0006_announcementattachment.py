# Generated by Django 5.0.7 on 2024-10-20 16:12

import django.db.models.deletion
import uuid
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('announcements', '0005_alter_announcement_updated_at'),
    ]

    operations = [
        migrations.CreateModel(
            name='AnnouncementAttachment',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('attachment_name', models.CharField(max_length=512)),
                ('attachment_type', models.CharField(choices=[('image/jpeg', 'JPEG'), ('image/PNG', 'PNG'), ('application/pdf', 'pdf'), ('application/msword', 'DOC'), ('application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'DOCX'), ('application/vnd.ms-excel', 'XLS'), ('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'XLSX')], max_length=128)),
                ('attachment_path', models.URLField(max_length=2048)),
                ('announcement', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='attachments', to='announcements.announcement')),
            ],
        ),
    ]
