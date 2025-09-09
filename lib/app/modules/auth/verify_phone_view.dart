import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/app/routes/app_routes.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';
import '../../core/values/colors.dart';
import '../../global_widgets/custom_button.dart';
import 'auth_controller.dart';

class VerifyPhoneView extends GetView<AuthController> {
  const VerifyPhoneView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // Title
              Text(
                Get.previousRoute == AppRoutes.forgotPassword
                    ? 'forgot_password_title'.tr
                    : 'otp_sent_message'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Description
              Text(
                'otp_sent_message'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Instruction
              Text(
                'enter_otp_instruction'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // OTP Input
              Directionality(
                textDirection: TextDirection.ltr,
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  onChanged: (value) {
                    controller.otpCode.value = value;
                  },
                  onCompleted: (value) {
                    controller.otpCode.value = value;
                  },
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 60,
                    fieldWidth: 60,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.border,
                    selectedColor: AppColors.primary,
                    borderWidth: 2,
                  ),
                  enableActiveFill: true,
                  keyboardType: TextInputType.number,
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Resend OTP with Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'didnt_receive_code'.tr,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.resendOTP,
                    child: Text(
                      'resend_otp'.tr,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Timer
              Obx(
                () => RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Expires in ',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: _formatTimer(controller.timerSeconds.value),
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 120),

              // Confirmation Button
              Obx(
                () => CustomButton(
                  text: 'confirmation'.tr,
                  onPressed: controller.otpCode.value.length == 6
                      ? controller.verifyOTP
                      : null,
                  isLoading: controller.isLoading.value,
                  width: double.infinity,
                  enabled: controller.otpCode.value.length == 6,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimer(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
