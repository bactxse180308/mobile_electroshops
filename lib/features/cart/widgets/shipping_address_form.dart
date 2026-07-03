import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import 'checkout_section.dart';

class ShippingAddressForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  const ShippingAddressForm({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return CheckoutSection(
      title: AppStrings.stepAddress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: AppStrings.fullNameLabel,
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            validator: _required,
          ),
          const SizedBox(height: AppSizes.p12),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: AppStrings.phoneLabel,
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            validator: _validatePhone,
          ),
          const SizedBox(height: AppSizes.p12),
          TextFormField(
            controller: addressController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: AppStrings.addressLabel,
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            validator: _required,
          ),
        ],
      ),
    );
  }

  static String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? AppStrings.errEmptyFields
        : null;
  }

  static String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.errEmptyFields;
    if (value.trim().length < 10) return AppStrings.errInvalidPhone;
    return null;
  }
}
