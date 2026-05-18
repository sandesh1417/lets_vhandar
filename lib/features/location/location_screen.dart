import 'package:flutter/material.dart';
import 'package:lets_vhandar/widgets/custom_scaffold_wrapper.dart';

class LocationNotServiceableScreen extends StatelessWidget {
  const LocationNotServiceableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldWrapper(
      isScrollable: true,
      horizontalPadding: 24,
      appBar: AppBar(
        leading: const CircleAvatar(
          backgroundColor: Colors.black,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: const Text(
          "Baneshwor - Baneshwor, Kathma..",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: const [
          Icon(Icons.keyboard_arrow_down),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              "Location not serviceable",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Our team is working tirelessly to bring 10 minutes deliveries to your location.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle location change
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Try Changing Location",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
