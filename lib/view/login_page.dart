import 'package:aqui_ajuda_app/common/colors.dart';
import 'package:aqui_ajuda_app/components/decoration_text_field.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();

  // essa hydra aqui é a tela de login
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.azulClaro,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentGeometry.topCenter,
            end: AlignmentGeometry.bottomCenter,
            colors: [MyColors.rosaClaro, MyColors.rosaEscuro],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/logo.png"),
                    const Text(
                      "Aqui Ajuda",
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Ajuda fácil",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    TextFormField(
                      decoration: getLoginInputDecoration(
                        "E-mail",
                        Icons.email,
                      ),
                      validator: (String? value) {
                        if (value == null) {
                          return "O e-mail não poder ser nulo";
                        }
                        if (value.length < 5) {
                          return "o e-mail é muito curto";
                        }
                        if (!value.contains("@")) {
                          return "O e-mail não é válido";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: getLoginInputDecoration(
                        "Senha",
                        Icons.password,
                      ),
                      obscureText: true,
                    ),
                    // apenas aparece se o usuário quiser se cadastrar
                    Visibility(
                      visible: !isLogin,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: getLoginInputDecoration(
                              "Confirme a senha",
                              Icons.password,
                            ),
                            obscureText: true,
                          ),
                          TextFormField(
                            decoration: getLoginInputDecoration(
                              "Nome",
                              Icons.account_circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        mainButtonPressed();
                      },
                      child: Text(isLogin ? "Entrar" : "Cadastrar"),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      child: Text(
                        isLogin
                            ? "Ainda não tem uma conta? Cadastre-se"
                            : "Já tem uma conta? Entre",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  mainButtonPressed() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pushNamed('/teste');
    } else {}
  }
}
