import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Floating "Support" button that opens a WhatsApp chat with the support
/// number returned by the `general/whatsapp-number` API, pre-filled with a
/// boilerplate enquiry message.
class SupportFab extends StatelessWidget {
  const SupportFab({Key? key}) : super(key: key);

  // Default country code used when the API returns a bare 10-digit number.
  static const String _defaultCountryCode = "91";
  static const String _boilerplateMessage = "Hello, I need help with the app.";

  Future<void> _openWhatsApp(BuildContext context) async {
    try {
      final response = await ApiRequest.get(
        url: "${AppConfig.BASE_URL}/general/whatsapp-number",
      );
      final decoded = jsonDecode(response.body);

      if (decoded["result"] != true ||
          decoded["whatsapp_number"] == null ||
          decoded["whatsapp_number"].toString().trim().isEmpty) {
        ToastComponent.showDialog("Support number is not available right now.");
        return;
      }

      final number = _normalizeNumber(decoded["whatsapp_number"].toString());
      final uri = Uri.parse(
          "https://wa.me/$number?text=${Uri.encodeComponent(_boilerplateMessage)}");

      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ToastComponent.showDialog("Could not open WhatsApp.");
      }
    } catch (e) {
      ToastComponent.showDialog("Could not open WhatsApp.");
    }
  }

  // wa.me needs the full international number (country code, digits only).
  String _normalizeNumber(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      digits = "$_defaultCountryCode$digits";
    }
    return digits;
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _openWhatsApp(context),
      backgroundColor: const Color(0xFF22BC5C),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: const Icon(Icons.support_agent, size: 24),
      label: const Text(
        "Support",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
