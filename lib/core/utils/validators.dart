class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu email';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um email válido';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira uma senha';
    }
    
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    }
    
    if (value != password) {
      return 'Senhas não coincidem';
    }
    
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um nome de usuário';
    }
    
    if (value.length < 3) {
      return 'Nome de usuário deve ter pelo menos 3 caracteres';
    }
    
    if (value.length > 20) {
      return 'Nome de usuário deve ter no máximo 20 caracteres';
    }
    
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+');
    if (!usernameRegex.hasMatch(value)) {
      return 'Nome de usuário pode conter apenas letras, números e _';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira $fieldName';
    }
    
    return null;
  }

  static String? validateItemName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira o nome do item';
    }
    
    if (value.trim().length < 2) {
      return 'Nome do item deve ter pelo menos 2 caracteres';
    }
    
    if (value.trim().length > 50) {
      return 'Nome do item deve ter no máximo 50 caracteres';
    }
    
    return null;
  }

  static String? validateCategoryName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira o nome da categoria';
    }
    
    if (value.trim().length < 2) {
      return 'Nome da categoria deve ter pelo menos 2 caracteres';
    }
    
    if (value.trim().length > 30) {
      return 'Nome da categoria deve ter no máximo 30 caracteres';
    }
    
    return null;
  }
}
