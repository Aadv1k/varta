# Generated by Django 5.0.7 on 2024-08-27 12:36

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0003_admin'),
    ]

    operations = [
        migrations.DeleteModel(
            name='Admin',
        ),
    ]