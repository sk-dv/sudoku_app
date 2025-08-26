enum TokenType {
  number,
  cats,
  seaAnimals,
  halloween;

  bool get isImage => this != TokenType.number;

  String get name {
    switch (this) {
      case TokenType.number:
        return 'NUMEROS';
      case TokenType.cats:
        return 'GATOS';
      case TokenType.seaAnimals:
        return 'ANIMALES MARINOS';
      case TokenType.halloween:
        return 'NOCHE DE BRUJAS';
    }
  }

  String get path {
    switch (this) {
      case TokenType.number:
        return '';
      case TokenType.cats:
        return 'assets/cats/';
      case TokenType.seaAnimals:
        return 'assets/sea_animals/';
      case TokenType.halloween:
        return 'assets/halloween/';
    }
  }

  String get token {
    switch (this) {
      case TokenType.number:
        return '';
      case TokenType.cats:
        return 'assets/cats/01.png';
      case TokenType.seaAnimals:
        return 'assets/sea_animals/01.png';
      case TokenType.halloween:
        return 'assets/halloween/01.png';
    }
  }
}
