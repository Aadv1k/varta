# Generated by Django 5.0.7 on 2024-11-18 05:45

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0001_initial'),
    ]

    operations = [
        migrations.AlterUniqueTogether(
            name='userdevice',
            unique_together=set(),
        ),
    ]