import 'package:url_launcher/url_launcher.dart';

Future<void> sendWhatsAppReminder(
    {required String studentName,
    required String studentPhoneNumber,
    required String formattedNextBillDate,
    required String chargePerMonth}) async {
  final message =
      'Hello $studentName, your payment of ₹$chargePerMonth is due on $formattedNextBillDate.';

  final uri =
      'https://wa.me/$studentPhoneNumber?text=${Uri.encodeComponent(message)}';

  final whatsappUrl = Uri.parse(uri);

  if (await launchUrl(whatsappUrl)) {
    await launchUrl(whatsappUrl);
  } else {
    // Handle an error, e.g., WhatsApp is not installed on the device
    print('Could not launch WhatsApp');
  }
}
