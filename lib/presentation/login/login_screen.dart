
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:onelot/application/shared_pref_helper.dart';
import 'package:onelot/application/utils/color_extension.dart';
import 'package:onelot/presentation/menu/menu_screen.dart';

import '../../application/utils/common_util.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late FToast fToast;
  String TYPE_ERROR = "error";
  String TYPE_SUCCESS = "success";

  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final textFieldFocusNode = FocusNode();
  bool _obscured = false;

  var btnColor = '#56B1E6'.toColor();

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldFocusNode.hasPrimaryFocus)
        return; // If focus is on text field, dont unfocus
      textFieldFocusNode.canRequestFocus =
      false; // Prevents focus if tap on eye
    });
  }

  Color boxColor = '#f2ecec'.toColor();
  Color bgColor = '#1e1e1e'.toColor();

  bool _loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fToast = FToast();
    fToast.init(context);

    Future.delayed(Duration.zero,(){
      Helper.getLoginSession().then((value) {
        if(value){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MenuScreen()));
        }
      });
    });

  }

  var currentFocus;

  unfocus() {
    currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unfocus,
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: formkey,
              child: Column(
                children: <Widget>[
                  SizedBox(
                      height: 100,
                      child: Container()),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text("Welcome Back!",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 24.0),),
                  ),
                  SizedBox(
                      height: 50,
                      child: Container()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: boxColor, // Border color
                          width: 1.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(10.0), // Radius for rounded corners
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Adjust padding inside the box
                        child: TextFormField(
                          controller: _usernameController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.grey),
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: '',
                            border: InputBorder.none, // Remove default border of TextFormField
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: boxColor, // Border color
                          width: 1.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(10.0), // Radius for rounded corners
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Adjust padding inside the box
                        child: TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: Colors.black),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _obscured,
                          focusNode: textFieldFocusNode,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            labelText: "Password",
                            labelStyle: const TextStyle(color: Colors.grey),
                            filled: false,
                            fillColor: boxColor,
                            isDense: true,
                            prefixIcon: Icon(
                                Icons.lock
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                              child: GestureDetector(
                                onTap: _toggleObscured,
                                child: Icon(
                                  _obscured
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  size: 24,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            border: InputBorder.none, // Remove default border of TextFormField
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: btnColor,
                          borderRadius: BorderRadius.circular(15)),
                      child: TextButton(
                        onPressed: (){
                          _submit(_usernameController.text, _passwordController.text);
                        },
                        child: _loading ? Center(child:
                        SizedBox( width: 20, height: 20, child: CircularProgressIndicator())) :  Text(
                          'Login',
                          style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          )),
    );
  }

  void _submit(String username, String password) async {
    bool isSuccess =false;
    String errorMsg = "";

    if(username.isEmpty || password.isEmpty){
      _showToast("Invalid input.", TYPE_ERROR);
    }else{
      unfocus();
      try {
        setState(() {
          _loading = true;
        });

        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _usernameController.text,
          password: _passwordController.text,
        );

        // TODO: Navigate to the next screen on successful login
        print('Login successful: ${userCredential.user!.email}');

        setState(() {
          isSuccess = true;
        });
      } catch (e) {
        errorMsg = e.toString();
        // Handle login errors
        print('Login failed: $e');
      } finally {

        setState(() {
          _loading = false;
        });

        if(isSuccess){
          Helper.saveLoginSession(true);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MenuScreen()));
        }else{
          _showToast(isSuccess ? "Login successful." : "Login failed. Please try again. \n Caused by : $errorMsg.", isSuccess?TYPE_SUCCESS:TYPE_ERROR);
      }
      }
    }
  }

  _showToast(String message,String type)  async{
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: type == "error" ? Colors.red : Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          toastIcon(type),
          const SizedBox(
            width: 12.0,
          ),
          Flexible(child: Text(message)),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

}
