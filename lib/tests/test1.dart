import 'package:flutter/material.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Plans'),
        backgroundColor: Colors.indigo, // Stripe-inspired color
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            PremiumPlanCard(
              title: 'Basic Plan',
              price: '₹99.00/month',
              features: const [
                'Up to 200 Students',
                'CSV Data Exports',
                'Ad-Free Experience',
              ],
            ),
            PremiumPlanCard(
              title: 'Pro Plan',
              price: '₹199.00/month',
              features: const [
                'Up to 500 Students',
                'High Quality Images',
                'All Basic Plan Features',
                'Priority Customer Support',
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class PremiumPlanCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;

  PremiumPlanCard({
    required this.title,
    required this.price,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.indigo, // Stripe-inspired color
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: ListTile(
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                price,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Divider(
            height: 0,
            color: Colors.grey,
          ),
          Column(
            children: features.map((feature) {
              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(
                  feature,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement the logic to subscribe to a plan here.
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.indigo, // Stripe-inspired color
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text('Choose This Plan',
                style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
