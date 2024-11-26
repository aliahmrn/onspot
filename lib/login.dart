import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/auth_service.dart';
import '../supervisor/main_navigator.dart';
import 'register.dart';
import 'forgot_password.dart';
import 'package:logger/logger.dart';

final logger = Logger();

// State class for login
class LoginState {
  final bool isAuthenticated; // Tracks if the user is logged in
  final bool isLoading;       // Tracks loading state
  final String errorMessage;  // Stores any error messages

  LoginState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage = '',
  });

  // Creates a copy of the current state with optional modifications
  LoginState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LoginState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}


// Define a StateNotifier to manage login logic
class LoginNotifier extends StateNotifier<LoginState> {
  final AuthService _authService;

  LoginNotifier(this._authService) : super(LoginState());

  Future<bool> login({
    required String input,
    required String password,
  }) async {
    if (input.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter both username/email and password');
      logger.e('Login failed: Missing username/email or password.');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: '');
    logger.i('Attempting login with username/email: $input');

    try {
      await _authService.login(input, password);
      logger.i('Login successful!');
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Invalid username/email or password');
      logger.e('Login failed: Invalid credentials');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
      logger.i('Login process completed.');
    }
  }
}

// Define a provider for LoginNotifier
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(AuthService()),
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

    return Scaffold(
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
                  child: Container(
                     decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary, // Use secondary color
                      borderRadius: BorderRadius.circular(15), 
                     ),
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
                                : () async {
                                    final input = _inputController.text;
                                    final password = _passwordController.text;

                                    final success = await loginNotifier.login(
                                      input: input,
                                      password: password,
                                    );

                                    if (success && context.mounted) {
                                      // Navigate to MainNavigator
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(builder: (context) => const MainNavigator()),
                                        (route) => false,
                                      );
                                    }
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
                                : Row(
                                    mainAxisSize: MainAxisSize.min, // Centers content inside the button
                                    children: [
                                      const Icon(Icons.login, color: Colors.white), // Add your desired icon
                                      const SizedBox(width: 8), // Add spacing between icon and text
                                      const Text('Sign In', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                          ),
                        const SizedBox(height: 10),
                        if (loginState.errorMessage.isNotEmpty) ...[
                          Text(
                            loginState.errorMessage,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center, // Aligns text horizontally within its bounds
                          ),
                          const SizedBox(height: 10),
                        ],
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const ForgotPasswordScreen(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Forgot Password?',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                decoration: TextDecoration.underline, // Adds the underline
                                decorationColor: Colors.grey, // Makes the underline grey
                                decorationThickness: 1.5, // Adjusts thickness
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const RegistrationScreen(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? Register",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                decoration: TextDecoration.underline, // Adds the underline
                                decorationColor: Colors.grey, // Makes the underline grey
                                decorationThickness: 1.5, // Adjusts thickness
                              ),
                            ),
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
    );
  }

Widget _buildInputField(String label, TextEditingController controller, {bool obscureText = false}) {
  IconData? getIcon(String label) {
    switch (label) {
      case 'Username or Email':
        return Icons.person; // Icon for username or email
      case 'Password':
        return Icons.lock; // Icon for password
      default:
        return null;
    }
  }

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
            prefixIcon: getIcon(label) != null ? Icon(getIcon(label), color: Colors.grey) : null,
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
            filled: true, // Enables the background color
            fillColor: Colors.white, // Sets the background color to white
            hintText: 'Enter $label',
            hintStyle: const TextStyle(color: Colors.grey), // Soft grey for hint text
          ),
        ),
      ),
    ],
  );
}
}
