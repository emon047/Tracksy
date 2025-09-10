import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';

//SignUpPage Widget 
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

//SignUpPage State 
class _SignUpPageState extends State<SignUpPage> {
  //Controllers & Variables 
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;

  //Build UI 
  @override
  Widget build(BuildContext context) {
    final service = Provider.of<SupabaseService>(context, listen: false);

    return Scaffold(
      //AppBar 
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), 
      ),

      //Body 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //Page Title 
              Text(
                'Create an account',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade900),
              ),
              const SizedBox(height: 16),

              //Full Name Input 
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: 'Full name', prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 12),

              //Email Input 
              TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email', prefixIcon: Icon(Icons.email))),
              const SizedBox(height: 12),

              //Phone Input 
              TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                      labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),

              //Password Input 
              TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                      labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                  obscureText: true),
              const SizedBox(height: 18),

              //Create Account Button 
              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final email = emailController.text.trim();
                        final phone = phoneController.text.trim();
                        final password = passwordController.text.trim();

                        //Validate Input 
                        if (name.isEmpty || email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please fill required fields')));
                          return;
                        }

                        setState(() => loading = true);

                        try {
                          //Sign up with Supabase 
                          await service.signUp(
                              email: email,
                              password: password,
                              name: name,
                              phone: phone);

                          setState(() => loading = false);

                          //Show Confirmation Message 
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Signed up. Please confirm your email before login.')));

                          Navigator.pop(context); 
                        } catch (e) {
                          setState(() => loading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
