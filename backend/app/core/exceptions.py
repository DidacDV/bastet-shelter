# app/core/exceptions.py

class ShelterException(Exception):
    """Base"""
    pass

class NotFoundError(ShelterException):
    """raised when entity doesnt exist"""
    def __init__(self, message: str):
        self.message = message

class BusinessLogicError(ShelterException):
    def __init__(self, message: str):
        self.message = message

class AuthorizationError(ShelterException):
    def __init__(self, message: str):
        self.message = message