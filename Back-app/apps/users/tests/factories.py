import factory
from faker import Faker

from apps.users.models import User

faker = Faker("pt_BR")


class UserFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = User
        skip_postgeneration_save = True

    email = factory.LazyAttribute(lambda _: faker.unique.email())
    full_name = factory.LazyAttribute(lambda _: faker.name())
    password = factory.PostGenerationMethodCall("set_password", "StrongPass123")
    role = User.Role.PASSENGER
