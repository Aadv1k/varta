# Generated by Django 5.0.7 on 2024-10-27 04:11

import django.db.models.deletion
import uuid
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('announcements', '0002_delete_announcementattachment'),
        ('attachments', '0003_remove_attachment_url_attachment_path_and_more'),
    ]

    operations = [
        migrations.RenameField(
            model_name='attachment',
            old_name='name',
            new_name='file_name',
        ),
        migrations.RenameField(
            model_name='attachment',
            old_name='type',
            new_name='file_type',
        ),
        migrations.RenameField(
            model_name='attachment',
            old_name='path',
            new_name='key',
        ),
        migrations.AlterField(
            model_name='announcementattachment',
            name='announcement',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='attachments', to='announcements.announcement'),
        ),
        migrations.AlterField(
            model_name='announcementattachment',
            name='attachment',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='attachments.attachment'),
        ),
        migrations.AlterField(
            model_name='attachment',
            name='id',
            field=models.UUIDField(default=uuid.uuid4, primary_key=True, serialize=False),
        ),
    ]
