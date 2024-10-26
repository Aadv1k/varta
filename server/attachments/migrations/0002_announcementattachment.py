# Generated by Django 5.0.7 on 2024-10-26 09:41

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('announcements', '0002_delete_announcementattachment'),
        ('attachments', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='AnnouncementAttachment',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('announcement', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='attachments', to='announcements.announcement')),
                ('attachment', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='attachments.attachment')),
            ],
        ),
    ]