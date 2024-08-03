from django.db import models

from django.core.validators import RegexValidator 

class PhoneNumberField(models.CharField):
    def __init__(self, *args, **kwargs):
        kwargs["max_length"] = 15
        super().__init__(*args, **kwargs)

        self.validators.append(RegexValidator(
            regex=r'^\+\d{10,15}$',
            message='Invalid phone number'
        ))
