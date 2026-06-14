import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/app_button.dart';

class _Slide {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _Slide({required this.icon, required this.color, required this.title, required this.body});
}

const _slides = [
  _Slide(icon: Icons.developer_board, color: AppColors.primary, title: AppStrings.onboarding1Title, body: AppStrings.onboarding1Sub),
  _Slide(icon: Icons.local_shipping_outlined, color: AppColors.accent, title: AppStrings.onboarding2Title, body: AppStrings.onboarding2Sub),
  _Slide(icon: Icons.verified_user_outlined, color: AppColors.success, title: AppStrings.onboarding3Title, body: AppStrings.onboarding3Sub),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _index = 0;

  void _next() {
    if (_index < _slides.length - 1) {
      setState(() => _index++);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _slides[_index];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                child: const Text(AppStrings.skipButton, style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _SlideView(slide: s, key: ValueKey(_index)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) => _Dot(active: i == _index, onTap: () => setState(() => _index = i))),
              ),
            ),
            const SizedBox(height: AppSizes.p24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
              child: AppButton(
                label: _index < _slides.length - 1 ? AppStrings.continueButton : AppStrings.startShoppingButton,
                variant: AppButtonVariant.gradient,
                size: AppButtonSize.lg,
                fullWidth: true,
                onPressed: _next,
              ),
            ),
            const SizedBox(height: AppSizes.p32),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 176,
            height: 176,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: slide.color.withValues(alpha: 0.08),
            ),
            child: Center(
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: slide.color.withValues(alpha: 0.12),
                  boxShadow: [BoxShadow(color: slide.color.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Icon(slide.icon, size: 64, color: slide.color),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(slide.title, style: AppTextStyles.h1, textAlign: TextAlign.center),
          const SizedBox(height: AppSizes.p12),
          Text(slide.body, style: const TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.6), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _Dot({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
        width: active ? 28 : 6,
        height: 6,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
