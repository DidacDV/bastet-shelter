from sqladmin import ModelView

from app.models.refuge import Refuge
from app.models.shelter import Shelter
from app.models.trait import Trait
from app.models.user import User
from app.models.login import Login
from app.models.shelter_member import ShelterMember
from app.models.animal import Animal
from app.models.province import Province

class ShelterAdmin(ModelView, model=Shelter):
    column_list = [Shelter.id, Shelter.name, Shelter.province_id, Shelter.volunteer_code]
    column_searchable_list = [Shelter.name, Shelter.volunteer_code]
    column_sortable_list = [Shelter.id, Shelter.name]
    name = "Shelter"
    name_plural = "Shelters"
    icon = "fa-solid fa-house"

class RefugeAdmin(ModelView, model=Refuge):
    column_list = [Refuge.id, Refuge.name, Refuge.shelter_id]
    column_searchable_list = [Refuge.name]
    icon = "fa-solid fa-paw"


class LoginAdmin(ModelView, model=Login):
    column_list = [Login.id, Login.email]
    column_searchable_list = [Login.email]
    icon = "fa-solid fa-envelope"

class UserAdmin(ModelView, model=User):
    column_list = [User.id, User.active]
    icon = "fa-solid fa-user"

class ShelterMemberAdmin(ModelView, model=ShelterMember):
    column_list = [ShelterMember.id, ShelterMember.user_id, ShelterMember.shelter_id, ShelterMember.role, ShelterMember.type, ShelterMember.join_date]
    column_searchable_list = [ShelterMember.type]
    column_sortable_list = [ShelterMember.join_date]
    icon = "fa-solid fa-users"

class AnimalAdmin(ModelView, model=Animal):
    column_list = [Animal.id, Animal.name, Animal.animal_type, Animal.breed, Animal.refuge_id]
    column_searchable_list = [Animal.name, Animal.breed]
    column_sortable_list = [Animal.id, Animal.name]
    icon = "fa-solid fa-cat"

class ProvinceAdmin(ModelView, model=Province):
    column_list = [Province.id, Province.name]
    column_searchable_list = [Province.name]
    column_sortable_list = [Province.id, Province.name]
    icon = "fa-solid fa-map-location-dot"

class TraitAdmin(ModelView, model=Trait):
    column_list = [Trait.id, Trait.name, Trait.shelter_id]
    icon = "fa-solid fa-map-location-dot"