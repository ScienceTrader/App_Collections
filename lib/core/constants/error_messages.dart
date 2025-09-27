class ErrorMessages {
  // Authentication errors
  static const String authEmailRequired = 'Email é obrigatório';
  static const String authPasswordRequired = 'Senha é obrigatória';
  static const String authInvalidEmail = 'Email inválido';
  static const String authWeakPassword = 'Senha muito fraca';
  static const String authUserNotFound = 'Usuário não encontrado';
  static const String authWrongPassword = 'Senha incorreta';
  static const String authEmailInUse = 'Email já está em uso';
  static const String authNetworkError = 'Erro de conexão. Verifique sua internet.';

  // Collection errors
  static const String collectionItemRequired = 'Nome do item é obrigatório';
  static const String collectionCategoryRequired = 'Nome da categoria é obrigatório';
  static const String collectionImageUploadFailed = 'Falha ao fazer upload da imagem';
  static const String collectionDeleteFailed = 'Falha ao excluir item';
  static const String collectionLimitReached = 'Limite de itens atingido';

  // Premium errors
  static const String premiumRequired = 'Recurso premium necessário';
  static const String premiumPaymentFailed = 'Falha no pagamento';
  static const String premiumSubscriptionError = 'Erro na assinatura';

  // Network errors
  static const String networkTimeout = 'Timeout da conexão';
  static const String networkNoConnection = 'Sem conexão com a internet';
  static const String networkServerError = 'Erro do servidor';
  static const String networkUnknownError = 'Erro desconhecido';

  // Validation errors
  static const String validationRequired = 'Campo obrigatório';
  static const String validationMinLength = 'Muito curto';
  static const String validationMaxLength = 'Muito longo';
  static const String validationInvalidFormat = 'Formato inválido';

  // Generic messages
  static const String genericError = 'Algo deu errado. Tente novamente.';
  static const String genericSuccess = 'Operação realizada com sucesso';
  static const String genericLoading = 'Carregando...';
  static const String genericTryAgain = 'Tente novamente';
}
