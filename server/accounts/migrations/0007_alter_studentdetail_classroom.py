# Generated by Django 5.0.7 on 2024-10-19 06:46

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0006_alter_studentdetail_classroom'),
    ]

    operations = [
        migrations.AlterField(
            model_name='studentdetail',
            name='classroom',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='accounts.classroom'),
        ),
    ]
