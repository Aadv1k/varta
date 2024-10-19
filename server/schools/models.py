from django.db import models

from common.fields.PhoneNumberField import PhoneNumberField

class School(models.Model):
    name = models.CharField(max_length=255)
    address = models.TextField()
    phone_number = PhoneNumberField()
    email = models.EmailField(unique=True)
    website = models.URLField(blank=True, null=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = "School"
        verbose_name_plural = "Schools"
    
class AcademicYear(models.Model):
    start_date = models.DateField()
    end_date = models.DateField()
    current = models.BooleanField(default=False)

    @staticmethod
    def get_current_academic_year():
        return AcademicYear.objects.get(current=True)
    
    def __str__(self):
        return f"{self.start_date.year}-{self.start_date.year}"

    class Meta:
        verbose_name = "Academic Year"
        verbose_name_plural = "Academic Years"
        ordering = ['-start_date']
