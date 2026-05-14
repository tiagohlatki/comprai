# ADR 001 — Flutter ao invés de React Native

**Status**: Aceito  
**Data**: 2025

## Contexto

Necessidade de app mobile com suporte a câmera nativa (QR Code) para Android e iOS com um único codebase.

## Decisão

Usar Flutter (Dart) como framework de desenvolvimento mobile.

## Justificativa

- Um codebase para Android e iOS
- Acesso nativo à câmera sem dependências problemáticas
- IA auxiliar (Claude) tem excelente suporte a Flutter/Dart
- Performance nativa via compilação AOT
- Ecossistema maduro para os casos de uso do MVP

## Consequências

- Time precisa aprender Dart (curva suave)
- React Native descartado definitivamente — não reabrir esta decisão
