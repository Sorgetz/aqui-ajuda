import 'package:aqui_ajuda_app/common/colors.dart';
import 'package:aqui_ajuda_app/components/decoration_text_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [MyColors.rosaClaro, MyColors.rosaEscuro],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Image.asset("assets/image.png", height: 120),
                ),

                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: getLoginInputDecoration(
                            "Email",
                            Icons.email,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Digite o e-mail";
                            if (!value.contains("@")) return "E-mail inválido";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: getLoginInputDecoration(
                            "Senha",
                            Icons.lock,
                          ),
                          obscureText: true,
                        ),
                        if (!isLogin) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: getLoginInputDecoration(
                              "Confirmar senha",
                              Icons.lock,
                            ),
                            obscureText: true,
                          ),
                        ],
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () {
                              mainButtonPressed();
                            },
                            child: Text(
                              isLogin ? "Entrar" : "Cadastrar",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        if (isLogin)
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Esqueceu a senha?",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),

                        const SizedBox(height: 8),

                        Text(
                          isLogin ? "Ou Entrar com" : "Ou Cadastrar-se com",
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(
                                  FontAwesomeIcons.google,
                                  color: Colors.red,
                                ),
                                label: const Text("Google"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(
                                  FontAwesomeIcons.facebook,
                                  color: Colors.blue,
                                ),
                                label: const Text("Facebook"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                          child: Text(
                            isLogin
                                ? "Não tem uma conta ainda? Cadastre-se"
                                : "Já tem cadastro? Faça o Login",
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  mainButtonPressed() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pushNamed('/teste');
    }
  }
}
