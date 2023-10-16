import 'package:flutter/material.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  PageController _pageController = PageController(viewportFraction: 0.8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Plans'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(bottom: 300),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        'Choose the Perfect Plan',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Select the plan that suits your needs.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 400,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return PremiumPlanCard(
                        title: 'Free Plan',
                        price: 'Free',
                        features: const [
                          'Up to 100 Students',
                          'All Payments Features',
                          'Reports and Analytics',
                          'Ad-Supported',
                        ],
                      );
                    } else if (index == 1) {
                      return PremiumPlanCard(
                        title: 'Basic Plan',
                        price: '₹99.00/month',
                        features: const [
                          'Up to 200 Students',
                          'CSV Data Exports',
                          'Ad-Free Experience',
                          'All Free Plan Features',
                        ],
                      );
                    } else {
                      return PremiumPlanCard(
                        title: 'Pro Plan',
                        price: '₹199.00/month',
                        features: const [
                          'Up to 500 Students',
                          'High Quality Images',
                          'All Basic Plan Features',
                          'Priority Customer Support',
                        ],
                      );
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // "Contact Us via WhatsApp" Button with improved styling
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {
                    // Implement the logic to open a WhatsApp chat here.
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // WhatsApp-inspired color
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.message, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Need Help? Contact US!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.indigo,
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
                  fontSize: 20,
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
                leading: const Icon(Icons.check_circle, color: Colors.indigo),
                title: Text(
                  feature,
                  style: const TextStyle(
                    fontSize: 18,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text(
              'Choose This Plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
