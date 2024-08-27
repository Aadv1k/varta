# Generated by Django 5.0.7 on 2024-08-27 14:58

import django.db.models.deletion
import uuid
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('schools', '__first__'),
    ]

    operations = [
        migrations.CreateModel(
            name='Classroom',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('standard', models.CharField(choices=[('1', '1'), ('2', '2'), ('3', '3'), ('4', '4'), ('5', '5'), ('6', '6'), ('7', '7'), ('8', '8'), ('9', '9'), ('10', '10'), ('11', '11'), ('12', '12')], max_length=2)),
                ('division', models.CharField(choices=[('A', 'A'), ('B', 'B'), ('C', 'C'), ('D', 'D'), ('E', 'E'), ('F', 'F'), ('G', 'G'), ('H', 'H'), ('I', 'I'), ('J', 'J')], max_length=1)),
            ],
        ),
        migrations.CreateModel(
            name='Department',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('department_name', models.CharField(max_length=64)),
            ],
        ),
        migrations.CreateModel(
            name='User',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('public_id', models.UUIDField(default=uuid.uuid4, editable=False)),
                ('first_name', models.CharField(max_length=255)),
                ('middle_name', models.CharField(blank=True, max_length=255, null=True)),
                ('last_name', models.CharField(max_length=255)),
                ('user_type', models.CharField(choices=[('teacher', 'Teacher'), ('student', 'Student')], default='student', max_length=8)),
                ('school', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='users', to='schools.school')),
            ],
        ),
        migrations.CreateModel(
            name='TeacherDetail',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('class_teacher_of', models.OneToOneField(null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='class_teacher_of', to='accounts.classroom')),
                ('departments', models.ManyToManyField(to='accounts.department')),
                ('subject_teacher_of', models.ManyToManyField(related_name='subject_teacher_of', to='accounts.classroom')),
                ('user', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='teacher_details', to='accounts.user')),
            ],
        ),
        migrations.CreateModel(
            name='StudentDetail',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('classroom', models.OneToOneField(null=True, on_delete=django.db.models.deletion.SET_NULL, to='accounts.classroom')),
                ('user', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='student_details', to='accounts.user')),
            ],
        ),
        migrations.CreateModel(
            name='UserContact',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('contact_importance', models.CharField(choices=[('primary', 'Primary'), ('secondary', 'Secondary')], max_length=10)),
                ('contact_type', models.CharField(choices=[('email', 'Email'), ('phone_number', 'Phone Number')], max_length=14)),
                ('contact_data', models.CharField(max_length=255)),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='contacts', to='accounts.user')),
            ],
        ),
    ]
