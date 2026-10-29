import 'package:flutter/material.dart';

const corPrimaria = Color(0xff00796b);
const corEscura = Color(0xff123c38);
const corFundo = Color(0xfff6faf9);
const corTextoSecundario = Color(0xff5f7370);
const corBorda = Color(0xffdbe7e5);

final temaApp = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: corPrimaria,
    primary: corPrimaria,
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: corFundo,
  appBarTheme: const AppBarTheme(
    backgroundColor: corFundo,
    surfaceTintColor: Colors.transparent,
    foregroundColor: corEscura,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: corEscura,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    errorMaxLines: 3,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: corBorda),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: corBorda),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: corPrimaria, width: 2),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: corBorda),
    ),
  ),
);
