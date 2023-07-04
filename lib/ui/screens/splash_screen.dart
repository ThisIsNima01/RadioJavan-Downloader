import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rj_downloader/config/global/constants/app_constants.dart';
import 'package:rj_downloader/ui/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double logoSize = 0;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        logoSize = 180;
      });
    });

    Future.delayed(
      const Duration(milliseconds: 4000),
      () {
        Get.offAll(() => const HomeScreen(),
            transition: Transition.rightToLeftWithFade,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeIn);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: Column(
        children: [
          const SizedBox(
            width: double.infinity,
          ),
          const Spacer(),
          AnimatedContainer(
            height: logoSize,
            duration: const Duration(milliseconds: 500),
            child: Image.asset(
              'assets/images/app_logo.png',
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          AnimatedOpacity(
            opacity: logoSize == 180 ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: const Text(
              'Easy Way To Download From \nRadio Javan !',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontFamily: 'pb'),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                'From',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                    fontFamily: 'pm'),
              ),
              const Text(
                'NIMA NADERI',
                style: TextStyle(
                    color: Colors.white, fontSize: 12, fontFamily: 'pb'),
              ),
            ],
          ),
          const SizedBox(
            height: 24,
          )
        ],
      ),
    );
  }
}
