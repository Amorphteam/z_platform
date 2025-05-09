import 'package:flutter/material.dart';

class HomeItemWidget extends StatelessWidget {
  final String text;
  final bool isLast;
  final bool isFirst;

  const HomeItemWidget({
    super.key,
    required this.text,
    this.isLast = false,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : 12,
        left: 16,
        right: 16,
        top: isFirst ? 8 : 8,
      ),
      child: Container(
        height: 80,
        child: Stack(
          children: [
            // Multiple background images
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Divider(
                      color: Colors.grey,
                      height: 0.5,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      (MediaQuery.of(context).size.width / 24).ceil(),
                      (index) => Image.asset(
                        'assets/image/bk_item.png',
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Divider(
                      color: Colors.grey,
                      height: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            // Teal card with text
            Center(
              child: Container(
                height: 66,
                width: MediaQuery.of(context).size.width / 1.5,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFFaec5c1).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/image/ali_kofi_light.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 