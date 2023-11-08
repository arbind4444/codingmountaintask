import 'package:codemtask/HomeScreen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../FbLogin/login_view.dart';
import '../Providers/fb_auth_method_providers.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final TextEditingController  email = TextEditingController();
  final TextEditingController  name = TextEditingController();
  final TextEditingController  password = TextEditingController();
  bool isLoading = false;



  @override
  Widget build(BuildContext context) {
    FBAuthMethod fbMethod =  Provider.of<FBAuthMethod>(context);
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1589802829985-817e51171b92?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8NXx8fGVufDB8fHx8fA%3D%3D'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(right: 35, left: 35),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: EdgeInsets.only(
                    left: 35,
                    top: 10,
                    bottom: MediaQuery.of(context).size.height * 0.2),
                child: const Text(
                  "Create\nAccount",
                  style: TextStyle(color: Colors.black, fontSize: 33),
                ),
              ),
              TextFormField(
                onChanged: (text) {},
                controller: name,
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
                  labelText: "Name",
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
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
                obscureText: true,
                cursorColor: Colors.teal,
                style: const TextStyle(
                  color: Colors.white,
                ),
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.teal,width: 3),
                  ),
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                 const Text(
                  'Sign Up',
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
                    color: Colors.white,
                    onPressed: () {
                      userRegister(fbMethod);
                    },
                    icon: isLoading == true ?const Center(child: CircularProgressIndicator(),): const Icon(Icons.arrow_forward),
                  ),
                ),
              ]),
              const SizedBox(
                height: 40,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Card(
                      color: Colors.teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const LoginView()));
                        },
                        child: const Center(
                          child: Text(
                            'Login  ',
                            style: TextStyle(
                              //decoration: TextDecoration.underline,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
            ]),
          ),
        ),
      ),
    );
  }
  userRegister(FBAuthMethod fbMethod){
    if(name.text.isNotEmpty&&email.text.isNotEmpty&&password.text.isNotEmpty){
      setState(() {
        isLoading = true;
      });
      fbMethod.fbSignUp(name.text,email.text,password.text).then((user) {
        if(user != null){
          setState(() {
            isLoading =false;
          });
          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>const HomeScreen(
          )));
          Fluttertoast.showToast(msg: "Signup successfully");
          print("Login successfully");
        }else{
          Fluttertoast.showToast(msg: "Signup field");
          print("Login field");
          setState(() {
            isLoading = false;
          });
        }
      });
    }else{
      Fluttertoast.showToast(msg: "Please fill form correctly");
      print("please entered all fields");
    }
  }
}
