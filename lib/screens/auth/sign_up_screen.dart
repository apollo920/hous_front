import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../components/buttons/socal_button.dart';
import '../../components/welcome_text.dart';
import '../../constants.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WelcomeText(
                title: "Create Account",
                text: "Enter your Name, Email and Password \nfor sign up.",
              ),

              // Sign Up Form
              const SignUpForm(),

              const SizedBox(height: defaultPadding),

              // Already have account
              Center(
                child: Text.rich(
                  TextSpan(
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontWeight: FontWeight.w500),
                    text: "Already have account? ",
                    children: <TextSpan>[
                      TextSpan(
                        text: "Sign In",
                        style: const TextStyle(color: primaryColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignInScreen(),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding),

              Center(
                child: Text(
                  "By Signing up you agree to our Terms \nConditions & Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: defaultPadding),

              kOrText,
              const SizedBox(height: defaultPadding),

              // Facebook
              SocalButton(
                press: () {},
                text: "Connect with Facebook",
                color: const Color(0xFF395998),
                icon: SvgPicture.asset(
                  'assets/icons/facebook.svg',
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF395998),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding),

              // Google
              SocalButton(
                press: () {},
                text: "Connect with Google",
                color: const Color(0xFF4285F4),
                icon: SvgPicture.asset(
                  'assets/icons/google.svg',
                ),
              ),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}

// Sign Up Form embutido aqui no mesmo arquivo
class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String username = '';
  String email = '';
  String password = '';
  bool isLoading = false;

  Future<void> register(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      // 1. Fazer login como admin
      final loginUrl = Uri.parse('http://10.0.2.2:8000/login/access-token');
      final loginResponse = await http.post(
        loginUrl,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': 'admin@example.com',
          'password': 'password',
        },
      );

      if (loginResponse.statusCode == 200) {
        final loginData = jsonDecode(loginResponse.body);
        final token = loginData['access_token'];

        // 2. Agora, com o token, criar o novo usuário
        final registerUrl = Uri.parse('http://10.0.2.2:8000/api/v1/users/');

        final registerResponse = await http.post(
          registerUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'email': email,
            'username': username,
            'password': password,
            'full_name': name,
            'is_active': true,
            'is_superuser': false,
            'company_id': 1,
          }),
        );

        if (registerResponse.statusCode == 200 || registerResponse.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadastro realizado com sucesso!')),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao realizar cadastro! (criação)')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao autenticar admin!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado ao cadastrar!')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
            onChanged: (value) => name = value,
            validator: (value) => value!.isEmpty ? 'Enter your name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Username',
            ),
            onChanged: (value) => username = value,
            validator: (value) => value!.isEmpty ? 'Enter your username' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email Address',
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => email = value,
            validator: (value) => value!.isEmpty ? 'Enter your email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            obscureText: true,
            onChanged: (value) => password = value,
            validator: (value) => value!.isEmpty ? 'Enter your password' : null,
          ),
          const SizedBox(height: 24),
          isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      register(context);
                    }
                  },
                  child: const Text('Sign Up'),
                ),
        ],
      ),
    );
  }
}