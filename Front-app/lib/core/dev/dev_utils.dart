import 'dart:math';
import 'package:faker/faker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Retorna true se o app está rodando em ambiente de desenvolvimento.
bool get isDev => dotenv.get('ENV', fallback: 'prod') == 'dev';

/// Gera dados falsos para preencher formulários automaticamente em dev.
class FakeData {
  static final _faker = Faker();
  static final _rng = Random();

  static String fullName() => _faker.person.name();

  static String email() => _faker.internet.email();

  /// Gera um CPF válido no formato 000.000.000-00.
  static String cpf() {
    final n = List.generate(9, (_) => _rng.nextInt(9));

    int d1 = 0;
    for (int i = 0; i < 9; i++) {
      d1 += n[i] * (10 - i);
    }
    d1 = (d1 * 10) % 11;
    if (d1 == 10) d1 = 0;

    int d2 = 0;
    for (int i = 0; i < 9; i++) {
      d2 += n[i] * (11 - i);
    }
    d2 += d1 * 2;
    d2 = (d2 * 10) % 11;
    if (d2 == 10) d2 = 0;

    final digits = [...n, d1, d2];
    return '${digits[0]}${digits[1]}${digits[2]}.'
        '${digits[3]}${digits[4]}${digits[5]}.'
        '${digits[6]}${digits[7]}${digits[8]}-'
        '${digits[9]}${digits[10]}';
  }

  static String carYear() {
    final year = 2010 + _rng.nextInt(14); // 2010–2023
    return year.toString();
  }

  static String carDoors() => (_rng.nextBool() ? 2 : 4).toString();
}
