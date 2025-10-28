import 'package:aqui_ajuda_app/common/colors.dart';
import 'package:aqui_ajuda_app/components/decoration_text_field.dart';
import 'package:aqui_ajuda_app/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLogin = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Informe o e-mail";
    if (!value.contains("@")) return "E-mail inválido";
    return null;
  }

  Widget? validationIcon(String? value, String? Function(String?) validator) {
    final error = validator(value);
    if (value == null || value.isEmpty) return null;
    return Icon(
      error == null ? Icons.check_circle : Icons.error,
      color: error == null ? Colors.green : Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [MyColors.rosaClaro, MyColors.rosaEscuro],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Image.asset("assets/image.png", height: 120),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: isLogin
                      ? buildLoginForm(context)
                      : buildRegisterForm(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLoginForm(BuildContext context) {
    return buildFormContainer(
      key: const ValueKey('login'),
      children: [
        TextFormField(
          controller: _emailController,
          decoration: getLoginInputDecoration("Email", Icons.email).copyWith(
            suffixIcon: validationIcon(_emailController.text, validateEmail),
          ),
          validator: validateEmail,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _passwordController,
          decoration: getLoginInputDecoration("Senha", Icons.lock),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        mainActionButton("Entrar", mainButtonPressed),
        TextButton(
          onPressed: showPasswordResetDialog,
          child: const Text(
            "Esqueceu a senha?",
            style: TextStyle(color: Colors.black87),
          ),
        ),
        const Divider(height: 32, thickness: 1),
        socialButtons(),
        toggleLoginRegister(),
      ],
    );
  }

  Widget buildRegisterForm(BuildContext context) {
    return buildFormContainer(
      key: const ValueKey('register'),
      children: [
        TextFormField(
          controller: _emailController,
          decoration: getLoginInputDecoration("Email", Icons.email).copyWith(
            suffixIcon: validationIcon(_emailController.text, validateEmail),
          ),
          validator: validateEmail,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _passwordController,
          decoration: getLoginInputDecoration("Senha", Icons.lock),
          obscureText: true,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: getLoginInputDecoration(
            "Confirmar senha",
            Icons.lock_outline,
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        mainActionButton("Cadastrar", mainButtonPressed),
        const Divider(height: 32, thickness: 1),
        socialButtons(),
        toggleLoginRegister(),
      ],
    );
  }

  Widget buildFormContainer({
    required List<Widget> children,
    required Key key,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(children: children),
      ),
    );
  }

  Widget mainActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text),
      ),
    );
  }

  Widget socialButtons() {
    return Column(
      children: [
        const Text("Ou continue com", style: TextStyle(color: Colors.black87)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final user = await _authService.signInWithGoogle();
                    if (user != null && mounted) {
                      Navigator.of(context).pushNamed('/teste');
                    }
                  } catch (e) {
                    showError(e.toString());
                  }
                },
                icon: const Icon(FontAwesomeIcons.google, color: Colors.red),
                label: const Text("Google"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(FontAwesomeIcons.facebook, color: Colors.blue),
                label: const Text("Facebook"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget toggleLoginRegister() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: GestureDetector(
        onTap: () => setState(() => isLogin = !isLogin),
        child: Text(
          isLogin
              ? "Não tem conta? Cadastre-se"
              : "Já possui conta? Faça login",
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  Future<void> showPasswordResetDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Recuperar senha"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Digite seu e-mail"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _authService.sendPasswordReset(controller.text.trim());
                showSuccess("E-mail de recuperação enviado!");
              } catch (e) {
                showError("Erro: $e");
              }
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  Future<void> mainButtonPressed() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (isLogin) {
        await _authService.signInWithEmail(email, password);
        if (mounted) Navigator.of(context).pushNamed('/teste');
      } else {
        if (password != _confirmPasswordController.text.trim()) {
          showError("As senhas não coincidem");
          return;
        }
        await _authService.registerWithEmail(email, password);
        showSuccess("Cadastro realizado! Verifique seu e-mail.");
      }
    } catch (e) {
      showError(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
