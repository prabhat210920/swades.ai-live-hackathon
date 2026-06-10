from django.contrib.auth.backends import ModelBackend
from .models import CustomUser


class PhoneNumberBackend(ModelBackend):
    """
    Authenticate using phone_number instead of the default username field.

    Django's authenticate() passes the value under the key 'username', so we
    look it up as phone_number in our CustomUser model.
    """

    def authenticate(self, request, username=None, password=None, **kwargs):
        # 'username' here is actually the phone_number string passed by the caller
        phone_number = username or kwargs.get("phone_number")
        if not phone_number:
            return None

        try:
            user = CustomUser.objects.get(phone_number=phone_number)
        except CustomUser.DoesNotExist:
            # Run the default password hasher to mitigate timing attacks
            CustomUser().set_password(password)
            return None

        if user.check_password(password) and self.user_can_authenticate(user):
            return user

        return None

    def get_user(self, user_id):
        try:
            return CustomUser.objects.get(pk=user_id)
        except CustomUser.DoesNotExist:
            return None
