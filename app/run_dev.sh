#!/bin/bash
# Executa o app em modo de desenvolvimento com as variáveis de ambiente locais
flutter run -d chrome --web-port=8080 --dart-define-from-file=.env
