# Generated by Django 5.0.7 on 2024-10-21 05:59

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0008_remove_usercontact_accounts_us_contact_583ef6_idx_and_more'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='userdevice',
            options={'verbose_name': 'User Device', 'verbose_name_plural': 'User Devices'},
        ),
        migrations.RemoveField(
            model_name='userdevice',
            name='last_used_at',
        ),
    ]
