# Generated by Django 5.0.7 on 2024-10-09 11:27

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('announcements', '0002_alter_announcement_academic_year'),
    ]

    operations = [
        migrations.AlterField(
            model_name='announcementscope',
            name='filter_data',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
    ]
