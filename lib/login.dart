import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/auth_service.dart';
import 'forgot_password.dart';
import 'register.dart';
import 'officer/homescreen.dart';

// Define a global navigator key provider
final navigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());

// Define a state class for login
class LoginState {
  final bool isLoading;
  final String errorMessage;

  LoginState({this.isLoading = false, this.errorMessage = ''});

  LoginState copyWith({bool? isLoading, String? errorMessage}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Define a StateNotifier to manage login logic
class LoginNotifier extends StateNotifier<LoginState> {
  final AuthService _authService;
  final GlobalKey<NavigatorState> _navigatorKey;

  LoginNotifier(this._authService, this._navigatorKey) : super(LoginState());

  Future<void> login({
    required String input,
    required String password,
  }) async {
    if (input.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter both username/email and password');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      await _authService.login(input, password);

      // Navigate to OfficerHomeScreen after successful login
      _navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => const OfficerHomeScreen()),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString() == 'Exception: Invalid login credentials.'
            ? 'Invalid login credentials.'
            : 'Failed to login: ${e.toString()}',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// Define a provider for LoginNotifier
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(AuthService(), ref.read(navigatorKeyProvider)),
);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final loginNotifier = ref.read(loginProvider.notifier);
    final navigatorKey = ref.read(navigatorKeyProvider);  // Read the navigator key

    return MaterialApp(
      navigatorKey: navigatorKey,  // Set navigatorKey for global access
      home: Scaffold(
        backgroundColor: const Color(0xFF2E5675),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 60),
                  Column(
                    children: [
                      Text(
                        'OnSpot',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Facility',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _buildInputField('Username or Email', _inputController),
                          const SizedBox(height: 20),
                          _buildInputField('Password', _passwordController, obscureText: true),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: loginState.isLoading
                                ? null
                                : () {
                                    loginNotifier.login(
                                      input: _inputController.text,
                                      password: _passwordController.text,
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              minimumSize: const Size(150, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            child: loginState.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Sign In', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 10),
                          if (loginState.errorMessage.isNotEmpty) ...[
                            Text(
                              loginState.errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 10),
                          ],
                          TextButton(
                            onPressed: () {
                              navigatorKey.currentState?.push(
                                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                              );
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              navigatorKey.currentState?.push(
                                MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                              );
                            },
                            child: const Text(
                              "Don't have an account? Register",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Transform.rotate(
                    angle: -90 * 3.1415926535 / 180,
                    child: Image.asset(
                      'assets/images/vacuum.png',
                      height: 200,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 350,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
