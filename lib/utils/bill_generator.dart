import 'package:cloud_functions/cloud_functions.dart';

// Initialize FirebaseFunctions
final FirebaseFunctions firebaseFunctions = FirebaseFunctions.instance;

Future<void> generateBills(String userId) async {
  print("Trying to generate bills");
  try {
    final HttpsCallable callable =
        firebaseFunctions.httpsCallable('generateBills');
    final result = await callable.call({'userId': userId});
    final data = result.data as Map<String, dynamic>;
    final message = data['message'] as String;
    print('Function result: $message');
  } catch (e) {
    print('Error calling function: $e');
    // Handle any errors here
  }
}
