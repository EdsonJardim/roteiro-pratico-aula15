import 'dart:io';
import 'package:flutter/material.dart';

class VisualizarFotoScreen extends StatelessWidget {
  final File imagem;

  const VisualizarFotoScreen({
    super.key,
    required this.imagem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Visualizar Foto'),
      ),
      body: Center(
        child: Hero(
          tag: 'foto-perfil',
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: Image.file(imagem),
          ),
        ),
      ),
    );
  }
}