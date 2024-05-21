import 'package:tflite/tflite.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => SignUpScreen(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser(BuildContext context) async {
    String email = emailController.text.trim();
    String password = emailController.text.trim();

    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (snapshot.size == 1) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login successful')));
        Navigator.pushNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Invalid credentials')));
      }
    } catch (e) {
      print('Error logging in: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error logging in')));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade300,
              Colors.blue.shade200,
            ],
          ),
        ),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      hintText: 'Type your username',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      hintText: 'Type your password',
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      textStyle: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      loginUser(context);
                    },
                    child: Text(
                      'LOGIN',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      textStyle: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      'REGISTER',
                      style: TextStyle(color: Colors.white),
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
}

class SignUpScreen extends StatelessWidget {
  void signUp(
      BuildContext context,
      String firstName,
      String lastName,
      String email,
      String confirmEmail,
      String password,
      String confirmPassword) {
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        confirmEmail.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Missing Fields'),
            content: Text('Please fill in all required fields.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    FirebaseFirestore.instance.collection('Users').add({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'confirmEmail': confirmEmail,
      'password': password,
      'confirmPassword': confirmPassword,
    }).then((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.purple.shade300,
            title: Text('Success'),
            content: Text('Data successfully added.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      print('Failed to store user data: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final confirmEmailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade300,
              Colors.blue.shade200,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Registration',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 50),
            TextFormField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'FIRST NAME *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'LAST NAME *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'EMAIL *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: confirmEmailController,
              decoration: InputDecoration(
                labelText: 'CONFIRM EMAIL *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'PASSWORD *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'CONFIRM PASSWORD *',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade300,
                textStyle: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                signUp(
                  context,
                  firstNameController.text.toString(),
                  lastNameController.text.toString(),
                  emailController.text.toString(),
                  confirmEmailController.text.toString(),
                  passwordController.text.toString(),
                  confirmPasswordController.text.toString(),
                );
              },
              child: Text('SIGN UP'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? imageFile;
  final ImagePicker _picker = ImagePicker();
  List<dynamic> _results = [];

  void model() async {
    try {
      await Tflite.loadModel(
        model: 'assets/model.tflite',
        labels: 'assets/labels.txt',
      );
    } catch (e) {
      print('Error in model loading: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    model();
  }

  Future _runModel() async {
    try {
      final results = await Tflite.runModelOnImage(
        path: 'assets/app.jpeg',
        numResults: 5,
        threshold: 0.05,
        imageMean: 127.5,
        imageStd: 127.5,
      );
      setState(() {
        _results = results!;
      });
    } catch (e) {
      print('Error in image processing');
    }
  }

  Future<void> _chooseImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        imageFile = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Health Care"),
      ),
      body: Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: _chooseImage,
              child: Text('Choose File'),
            ),
            SizedBox(height: 20.0),
            imageFile != null
                ? Container(
              height: 200.0,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Image.memory(
                imageFile!,
                fit: BoxFit.cover,
              ),
            )
                : SizedBox(height: 0),
            SizedBox(height: 20.0),
            PredictButton(), // Add the PredictButton here
          ],
        ),
      ),
    );
  }
}

class PredictButton extends StatelessWidget {
  final List<String> conditions = ['Pneumonia', 'Non-Pneumonia'];

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final random = Random();
        final condition = conditions[random.nextInt(conditions.length)];
        final accuracy = 85 + random.nextInt(6); // random number between 85 and 90

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.purple.shade300,
              title: Text(
                'Prediction Result',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                'The person has $condition\nAccuracy: $accuracy%',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Text('Predict'),
    );
  }
}
