import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeItemWidget extends StatelessWidget {
  final String text;
  final bool isLast;
  final bool isFirst;
  final VoidCallback? onTap;

  const HomeItemWidget({
    super.key,
    required this.text,
    this.isLast = false,
    this.isFirst = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(
          bottom: isLast ? 0 : 4,
          left: 16,
          right: 16,
          top: isFirst ? 4 : 4,
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
                    color: Color(0xFFb5c8c9).withOpacity(0.8),
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
                        child: AutoSizeText(
                          text,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'almarai'),
                          maxLines: 1,
                          minFontSize: 12,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/image/ali-kofi.svg',
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,),
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
} 