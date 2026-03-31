/// Dados de KYC (Know Your Customer) do Motorista.
/// Regras equivalentes à 99 e Uber.
class DriverKycPayload {
  final String cpf;
  final String fullyName;
  final String phoneVerified;
  
  // Condutor
  final String cnhFilePath;
  final String selfieFilePath;
  final bool hasEar; // Exerce Atividade Remunerada
  final bool isDefinitiveCnh; // Não pode ser PPD (Provisória)
  final bool backgroundCheckConsent; // Aceitou checagem criminal?
  
  // Veículo
  final String crlvFilePath;
  final int carYear; // <= 10 anos ou regra da cidade
  final int carDoors; // Ex: 4 portas
  final bool hasAc; // Ar-condicionado obrigatório
  final int seatCapacity; // Min. 5 (incluindo condutor)
  final bool isNotPickupOrVan; // Restrição estrutural
  
  DriverKycPayload({
    required this.cpf,
    required this.fullyName,
    required this.phoneVerified,
    required this.cnhFilePath,
    required this.selfieFilePath,
    required this.hasEar,
    required this.isDefinitiveCnh,
    required this.backgroundCheckConsent,
    required this.crlvFilePath,
    required this.carYear,
    required this.carDoors,
    required this.hasAc,
    required this.seatCapacity,
    required this.isNotPickupOrVan,
  });

  /// Validação básica Front-End antes de enviar para não sobrecarregar API.
  String? validateClientSide() {
    if (!isDefinitiveCnh) return 'Apenas CNH definitiva é aceita. PPD negada.';
    if (!hasEar) return 'A CNH precisa conter a anotação EAR.';
    if (!backgroundCheckConsent) return 'É necessário autorizar a checagem de antecedentes.';
    if (carDoors < 4) return 'O veículo deve possuir 4 portas.';
    if (!hasAc) return 'Ar-condicionado é obrigatório e precisa estar gelando.';
    if (seatCapacity < 5) return 'O veículo deve portar no mínimo 5 lugares.';
    if (!isNotPickupOrVan) return 'Caminhonetes (Pick-ups) e Vans não são permitidas.';
    
    // Obs: Ano de fabricação (carYear >= 2016) tipicamente não se restringe localmente
    // porque há cidades que aceitam 8 anos de janela, outras 10 anos. 
    // É o Backend quem deve autorizar localidade vs ano.
    return null;
  }
}

/// Dados de Cadastro inicial do Passageiro.
class PassengerRegistrationPayload {
  final String cpf;
  final String fullName;
  final String email;
  final String phoneVerified;
  final bool isOver18;
  // Modo de pagamento pré-selecionado (Card, Pix, Cash)
  final String defaultPaymentMethod;

  PassengerRegistrationPayload({
    required this.cpf,
    required this.fullName,
    required this.email,
    required this.phoneVerified,
    required this.isOver18,
    required this.defaultPaymentMethod,
  });

  String? validateClientSide() {
    if (!isOver18) return 'Você deve ter ao menos 18 anos, ou andar assistido por um adulto verificado.';
    if (cpf.isEmpty || cpf.length < 11) return 'CPF Inválido.';
    return null;
  }
}
