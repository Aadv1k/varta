# Generated by Django 5.0.7 on 2024-11-13 13:02

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('schools', '0002_alter_school_address_alter_school_email'),
    ]

    operations = [
        migrations.AlterField(
            model_name='school',
            name='address',
            field=models.TextField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name='school',
            name='email',
            field=models.EmailField(default='foo@bar.com', max_length=254, unique=True),
            preserve_default=False,
        ),
    ]
