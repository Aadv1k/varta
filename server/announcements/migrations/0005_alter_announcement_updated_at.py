# Generated by Django 5.0.7 on 2024-10-14 08:12

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('announcements', '0004_announcement_deleted_at_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='announcement',
            name='updated_at',
            field=models.DateTimeField(null=True),
        ),
    ]
