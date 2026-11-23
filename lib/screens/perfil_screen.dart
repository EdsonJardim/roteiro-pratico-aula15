import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/media_service.dart';
import 'visualizar_foto_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _mediaService = MediaService();
  File? _imagemPerfil;
  final _nomeController = TextEditingController(text: 'Meu Perfil');

  @override
  void initState() {
    super.initState();
    _carregarFotoSalva();
  }

  Future<void> _carregarFotoSalva() async {
    final preferencias = await SharedPreferences.getInstance();
    final caminho = preferencias.getString('foto_perfil');

    if (caminho != null && File(caminho).existsSync()) {
      if (!mounted) return;

      setState(() {
        _imagemPerfil = File(caminho);
      });
    }
  }

  Future<void> _salvarFoto(String caminho) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString('foto_perfil', caminho);
  }

  Future<void> _capturarImagem(bool daCamera) async {
    Navigator.pop(context);

    final File? imagem = daCamera
        ? await _mediaService.tirarFoto()
        : await _mediaService.selecionarDaGaleria();

    if (!mounted) return;

    if (imagem != null) {
      setState(() {
        _imagemPerfil = imagem;
      });

      await _salvarFoto(imagem.path);
    }
  }

  Future<void> _removerFoto() async {
    Navigator.pop(context);

    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove('foto_perfil');

    if (!mounted) return;

    setState(() {
      _imagemPerfil = null;
    });
  }

  void _exibirOpcoesMidia() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 230,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.pink),
              title: const Text('Tirar Foto com a Câmera'),
              onTap: () => _capturarImagem(true),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.pink),
              title: const Text('Escolher da Galeria'),
              onTap: () => _capturarImagem(false),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remover Foto'),
              onTap: _removerFoto,
            ),
          ],
        ),
      ),
    );
  }

  void _visualizarFoto() {
    if (_imagemPerfil == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisualizarFotoScreen(
          imagem: _imagemPerfil!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _visualizarFoto,
                    child: Hero(
                      tag: 'foto-perfil',
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.pink.shade100,
                        backgroundImage: _imagemPerfil != null
                            ? FileImage(_imagemPerfil!)
                            : null,
                        child: _imagemPerfil == null
                            ? const Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.pink,
                              )
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: FloatingActionButton.small(
                      onPressed: _exibirOpcoesMidia,
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}