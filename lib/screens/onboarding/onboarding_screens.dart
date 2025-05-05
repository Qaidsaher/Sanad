import 'package:sanad/core/localization/language.dart';
import 'package:sanad/core/theme/theme_controller.dart';
import 'package:sanad/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
     OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  String? selectedLangCode;
  int? selectedThemeIndex;

  final List<Map<String, String>> pages = [
    {'image': 'assets/onboarding/1.png'},
    {'image': 'assets/onboarding/2.png'},
    {'image': 'assets/onboarding/3.png'},
    {'image': 'assets/onboarding/4.png'},
  ];

  final List<Color> backgroundColors = [
       Color(0xFFFFFAED),
       Color(0xFFF8F8F7),
       Color(0xFFFEF6EF),
       Color(0xFFF8F8F8),
  ];

  final List<Color> themeColors = [
    Color(0xFF0D47A1), // Blue Light Theme
    Color(0xFF1A237E), // Indigo Dark Theme
    Color(0xFF388E3C), // Green Light Theme
    Color(0xFF2E7D32), // Green Dark Theme
    Color(0xFFD32F2F), // Red Light Theme
    Color(0xFFB71C1C), // Red Dark Theme
  ];

  void _onSkip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboardingSeen", true);
    Get.off(() =>    SplashScreen());
  }

  void _onNext() async {
    if (currentIndex == pages.length - 1) {
      _onSkip();
    } else {
      _pageController.nextPage(
        duration:    Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pages.length,
        (index) => AnimatedContainer(
          duration:    Duration(milliseconds: 300),
          margin:    EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 12 : 8,
          height: currentIndex == index ? 12 : 8,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? Theme.of(context).primaryColor
                : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, String> data, int index) {
    return Container(
      color: backgroundColors[index],
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        data['image']!,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildLanguageButtons() {
    final languages = Get.find<LanguageController>().languages;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: languages.map((lang) {
        final bool isSelected = selectedLangCode == lang['locale'].languageCode;
        return ElevatedButton(
          onPressed: () {
            setState(() {
              selectedLangCode = lang['locale'].languageCode;
            });
            Get.find<LanguageController>().setLanguage(lang['locale']);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? Theme.of(context).primaryColor : Colors.white,
            foregroundColor: isSelected ? Colors.white : Colors.black,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: isSelected
                  ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                  : BorderSide.none,
            ),
            padding:    EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          ),
          child: Text(lang['name'], style:    TextStyle(fontSize: 13)),
        );
      }).toList(),
    );
  }

  Widget _buildThemeButtons() {
    final themeController = Get.find<ThemeController>();

    return Container(
      color: backgroundColors[currentIndex],
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: themeColors.asMap().entries.map((entry) {
          final index = entry.key;
          final color = entry.value;
          final isSelected = selectedThemeIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedThemeIndex = index;
              });
              themeController.setTheme(index);
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                // match page bg
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) => _buildPage(pages[index], index),
          ),
          Positioned(
            right: 16,
            top: 40,
            child: TextButton(
              onPressed: _onSkip,
              child:
                  Text("skip".tr, style:    TextStyle(color: Colors.grey)),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: _buildDots(),
          ),
          if (currentIndex == pages.length - 1) ...[
            Positioned(
              bottom: 138,
              left: 0,
              right: 0,
              child: _buildLanguageButtons(),
            ),
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: _buildThemeButtons(),
            ),
          ],
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding:    EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                currentIndex == pages.length - 1 ? "get_started".tr : "next".tr,
                style:    TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
