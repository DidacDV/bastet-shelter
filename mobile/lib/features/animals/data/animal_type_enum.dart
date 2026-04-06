enum AnimalTypeEnum {
  cat,
  dog;

  String get value {
    switch (this) {
      case AnimalTypeEnum.cat:
        return 'CAT';
      case AnimalTypeEnum.dog:
        return 'DOG';
    }
  }

  String get label {
    switch (this) {
      case AnimalTypeEnum.cat:
        return 'Cat';
      case AnimalTypeEnum.dog:
        return 'Dog';
    }
  }
}
