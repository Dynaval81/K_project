import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../main_app.dart';
import '../../constants/app_colors.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  final String nickname;
  final String vtalkNumber;

  RegistrationSuccessScreen({
    required this.nickname,
    required this.vtalkNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.accentGreen,
                    size: 32,
                  ),
                  SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Registration Successful',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 40),
              
              Text(
                'Your Vtalk ID:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
              
              SizedBox(height: 10),
              
              Text(
                '@$nickname',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              
              SizedBox(height: 30),
              
              // ⭐ ИСПРАВЛЕНО: VT- как неактивный префикс
              Column(
                children: [
                  Text(
                    'Your Vtalk Number:',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '(tap to copy)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white38,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 10),
              
              // ⭐ ИСПРАВЛЕНО: При клике копируются только цифры
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: vtalkNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Number copied: $vtalkNumber'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ⭐ VT- неактивный (серый)
                      Text(
                        'VT-',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white38,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      // ⭐ Только цифры зелёные (это и копируется)
                      Text(
                        vtalkNumber,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGreen,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.copy,
                        color: AppColors.accentGreen,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 40),
              
              Text(
                'Remember this number!\nYou\'ll need it to login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                ),
              ),
              
              SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(builder: (context) => MainApp(initialTab: 3)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}