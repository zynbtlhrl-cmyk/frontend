import 'package:flutter/material.dart';

class SectionBox extends StatelessWidget {
  final String title;
  final String button;
  final Widget child;
  final VoidCallback onButtonTap;

  const SectionBox({
    super.key,
    required this.title,
    required this.button,
    required this.child,
    required this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔵 العنوان + زر الإضافة
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 140),

                // 🔥 زر إضافة مضمون (Material + InkWell)
                TextButton.icon(
                  onPressed: onButtonTap,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(button),
                  onLongPress: () {
                    print('object');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(),

            // 🔥 مهم: حتى ما يتمدد ويغطي الزر
            Flexible(fit: FlexFit.loose, child: child),

            const SizedBox(height: 15),

            const Text("عرض الكل", style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
