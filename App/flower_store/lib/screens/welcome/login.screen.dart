import 'package:flower_store/services/share_pre.dart';
import 'package:flower_store/services/sign_in.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flower_store/constants/colors.dart';
import 'package:flower_store/models/authorize/login.model.dart';
import 'package:flower_store/screens/forgot_password/forgot.password.dart';
import 'package:flower_store/screens/mainpage/mainpage.screen.dart';
import 'package:flower_store/screens/welcome/register.screen.dart';
import 'package:flower_store/services/authorize.service.dart';
import '../../shared/components/input_decoration.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginForm = GlobalKey<FormBuilderState>();
  static AuthorizeService authorizeService = AuthorizeService();
  final SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: gradientBackground,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
            child: Column(
              children: [
                // Image.asset(
                //   'assets/images/logo_shop.png',
                //   width: 200,
                // ),
                const Text(
                  "Đăng nhập",
                  style: TextStyle(
                      fontSize: 28,
                      color: Color.fromARGB(255, 9, 9, 9),
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                FormBuilder(
                    key: _loginForm,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(children: getLoginForm())),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final LoginResult result =
                        await FacebookAuth.instance.login();
                    if (result.status == LoginStatus.success &&
                        result.accessToken != null) {
                      String token = result.accessToken!.token;
                      await SignInService().sendTokenToBackend(token, context);
                    } else {
                      _showErrorDialog(context,
                          'Lỗi đăng nhập hoặc accessToken không tồn tại.');
                    }
                  },
                  child: Text('Login with Facebook'),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text(
                    "Tạo tài khoản mới ?",
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const RegisterScreen()));
                    },
                    child: const Text(
                      "Đăng ký ",
                      style: TextStyle(color: Color(0xff920000)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  List<Widget> getLoginForm() {
    return [
      genericFieldContainer(
          field: FormBuilderTextField(
              name: 'email',
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
              decoration: genericInputDecoration(label: 'Email'))),
      genericFieldContainer(
        field: FormBuilderTextField(
          name: 'password',
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          decoration: genericInputDecoration(label: 'Mật khẩu'),
        ),
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerRight,
        child: SizedBox(
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen()),
              );
            },
            child: const Text(
              'Quên mật khẩu',
              style: TextStyle(color: Color(0xff920000)),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      MaterialButton(
        color: const Color(0xFFFFEED0),
        minWidth: double.infinity,
        padding: const EdgeInsets.all(15),
        shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.transparent)),
        elevation: 10,
        focusElevation: 5,
        onPressed: () async {
          // Validate and save the form values
          if (_loginForm.currentState!.saveAndValidate()) {
            LoginModel model = LoginModel();
            model.fromJsonMapping(_loginForm.currentState!.value);
            try {
              var val = await authorizeService.login(model);
              debugPrint('Login response: ${val.toJson()}');
              await sharedPreferencesService.saveAccountInfo(val);
              debugPrint('Account info saved: ${val.toJson()}');
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const MainPageScreen()));
            } catch (onError) {
              debugPrint('Login error: $onError');
              Fluttertoast.showToast(
                  msg: "Sai mật khẩu hoặc email",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          }
        },
        child: const Text(
          'Đăng nhập',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    ];
  }
}
