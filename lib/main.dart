import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const UserApp());
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coins Challenge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> recordLogin(String method) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance.collection('login_events').add({
      'email': user.email ?? '',
      'method': method,
      'event': 'login',
      'platform': 'Android',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login() async {
    setState(() => loading = true);

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (credential.user != null) {
        await recordLogin('Email');
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'حدث خطأ أثناء تسجيل الدخول'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : login,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('تسجيل الدخول'),
              ),
            ),

            const SizedBox(height: 10),

            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Google Login يحتاج إعداد Google Sign-In في Firebase',
                    ),
                  ),
                );
              },
              child: const Text('متابعة باستخدام Google'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coins Challenge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'مرحباً ${user?.email ?? ''}',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            const Text(
              '🪙 Coins: 0',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // هنا تضيف نظام التحديات لاحقاً
              },
              child: const Text('ابدأ التحدي'),
            ),
          ],
        ),
      ),
    );
  }
}