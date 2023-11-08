import 'package:codemtask/FbSignup/signup_view.dart';
import 'package:codemtask/HomeScreen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Providers/fb_auth_method_providers.dart';
import '../Providers/google_signing_providers.dart';
import 'package:provider/provider.dart';



class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}



class _LoginViewState extends State<LoginView> {

  final TextEditingController  email = TextEditingController();
  final TextEditingController  password = TextEditingController();
  bool isLoading = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    GoogleSigningAuthProvider authProvider = Provider.of<GoogleSigningAuthProvider>(context);
    FBAuthMethod fbMethod =  Provider.of<FBAuthMethod>(context);
    google(BuildContext context)  {
      authProvider.googleSigning().then((isSuccess){
        setState(() {
          loading = false;
          if (isSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>  const HomeScreen(),
              ),
            );
          }
        });
      }).catchError((error, stackTrace) {
        Fluttertoast.showToast(msg: error.toString());
        authProvider.handleException();
      });
    }

    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Sign in fail");
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "Sign in canceled");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Sign in success");
        break;
      default:
        break;
    }
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1589802829985-817e51171b92?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8NXx8fGVufDB8fHx8fA%3D%3D'), fit: BoxFit.cover),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(
                right: 35,
                left: 35,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: 35,
                          top: MediaQuery.of(context).size.height * 0.1,
                          bottom: MediaQuery.of(context).size.height * 0.2),
                      child: const Text(
                        "Welcome\nBack",
                        style: TextStyle(color: Colors.black, fontSize: 33),
                      ),
                    ),
                    TextFormField(
                      onChanged: (text) {},
                      controller: email,
                      cursorColor: Colors.teal,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.teal,width: 3),
                        ),
                        labelText: "Email",
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),

                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      onChanged: (text) {},
                      controller: password,
                      cursorColor: Colors.teal,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.teal,width: 3),
                        ),
                        labelText: "Password",
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),

                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.teal,
                          child: IconButton(
                            color: Colors.black,
                            onPressed: () {
                              loginButton(fbMethod);
                            },
                            icon: isLoading == true ?const Center(child: CircularProgressIndicator(),): const Icon(Icons.arrow_forward,color: Colors.white,),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                       // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Card(
                            color: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                    const SignUpScreen()));
                              },
                              child: const Center(
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    // decoration: TextDecoration.underline,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                    const SizedBox(
                      height: 10,
                    ),
                    loading? const Center(child: CircularProgressIndicator(color: Colors.white,)):  Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                           color: Colors.teal,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Image.network(
                              'http://pngimg.com/uploads/google/google_PNG19635.png',
                              fit:BoxFit.cover
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                           Center(
                              child: GestureDetector(
                                  onTap: () async {
                                    google(context);
                                    setState(() {
                                      loading = true;
                                    });
                                  },
                                  child:const Text(
                                    "Signing with Google",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white
                                    ),
                                  )
                              )),

                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                           color: Colors.teal,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          const Icon(Icons.facebook),
                          const SizedBox(
                            width: 15,
                          ),
                          Center(
                              child: GestureDetector(
                                  onTap: () async {
                                    // google(context);
                                    // setState(() {
                                    //   loading =true;
                                    // });
                                  },
                                  child:const Text(
                                    "Signing with FaceBook",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white
                                    ),
                                  )
                              )),

                        ],
                      ),
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
  loginButton(FBAuthMethod fbMethod){
    if(email.text.isNotEmpty && password.text.isNotEmpty){
      setState(() {
        isLoading = true;
      });
      fbMethod.fbLogIn(email.text, password.text).then((user) {
        if(user != null){
          Fluttertoast.showToast(msg: "Login successfully");
          print("login successfully");
          setState(() {
            isLoading = false;
          });
           Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomeScreen()));
        }else{
          Fluttertoast.showToast(msg: "Login Field");
          print('login Field');
          setState(() {
            isLoading = false;
          });
        }
      });
    }else{
      Fluttertoast.showToast(msg: "Please fill form correctly");
      print("Please fill form correctly");
    }
  }
}
