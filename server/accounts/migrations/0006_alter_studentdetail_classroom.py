# Generated by Django 5.0.7 on 2024-10-19 06:45

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0005_alter_user_options_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='studentdetail',
            name='classroom',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to='accounts.classroom'),
        ),
    ]
