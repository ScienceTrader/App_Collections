# My Collection App

Um aplicativo completo para gerenciamento de coleções com recursos sociais e premium.

## Funcionalidades

### Gratuitas
- ✅ Até 5 categorias e 100 itens
- ✅ Feed social público
- ✅ Sistema de likes e comentários
- ✅ Seguir outros usuários
- ✅ Notificações básicas

### Premium
- ⭐ Coleções ilimitadas
- ⭐ Análises detalhadas
- ⭐ Chat com outros usuários
- ⭐ Promoção de itens
- ⭐ Relatórios PDF/Excel
- ⭐ Suporte prioritário

## Tecnologias

- **Flutter** - Framework UI
- **GetX** - Gerenciamento de estado
- **Supabase** - Backend e banco de dados
- **Stripe** - Sistema de pagamentos
- **Firebase** - Push notifications
- **Clerk** - Autenticação

## Setup do Projeto

### 1. Clone o repositório
```bash
git clone https://github.com/seu-usuario/my-collection-app.git
cd my-collection-app
```

### 2. Instale as dependências
```bash
flutter pub get
```

### 3. Configure as variáveis de ambiente
```bash
cp .env.example .env
# Edite o arquivo .env com suas chaves
```

### 4. Configure os serviços

#### Supabase
1. Crie um projeto em [supabase.com](https://supabase.com)
2. Execute o script SQL em `database/schema.sql`
3. Configure os buckets de storage
4. Adicione URL e chaves no `.env`

#### Stripe
1. Crie uma conta em [stripe.com](https://stripe.com)
2. Configure os produtos Premium
3. Adicione chaves no `.env`

#### Firebase
1. Crie projeto em [firebase.google.com](https://firebase.google.com)
2. Ative Cloud Messaging
3. Configure para Android/iOS
4. Baixe arquivos de configuração

#### Clerk
1. Crie conta em [clerk.com](https://clerk.com)
2. Configure providers de autenticação
3. Adicione chave pública no `.env`

### 5. Execute o projeto
```bash
flutter run
```

## Estrutura do Projeto

```
lib/
├── main.dart                    # Entry point
├── app/                         # Configuração do app
├── core/                        # Serviços e constantes
├── features/                    # Funcionalidades por módulo
├── shared/                      # Código compartilhado
└── assets/                      # Recursos do app
```

## Scripts Úteis

```bash
# Executar em desenvolvimento
flutter run

# Build para produção
flutter build apk --release      # Android
flutter build ios --release      # iOS

# Executar testes
flutter test

# Analisar código
flutter analyze

# Limpar build cache
flutter clean
```

## Deploy

### Android
1. Configure signing no `android/app/build.gradle`
2. Execute `flutter build apk --release`
3. Upload para Google Play Console

### iOS
1. Configure certificados no Xcode
2. Execute `flutter build ios --release`
3. Archive e upload para App Store Connect

## Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push