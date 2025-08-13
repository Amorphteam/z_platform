import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../util/style_helper.dart';

class AboutUsSheetWidget extends StatelessWidget {
  const AboutUsSheetWidget({super.key});

  @override
  Widget build(BuildContext context) => Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header with X icon and title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                 Expanded(
                  child: Text(
                    'حول التطبيق ',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 48), // Balance the close button
              ],
            ),
          ),

          // HTML content area
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 0, bottom: 16, left: 16, right: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: SingleChildScrollView(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Html(
                    data: '''
<body>
  <p class="center">بسم الله الرحمن الرحيم</p>

  <p>التطبيق الماثل بين أيديكم الكريمة يشتمل على الأثر الخالد والمصنف الفريد (نهج البلاغة)، الكتاب الذي جمع بين دفتيه جانباً مهماً من كلام أمير المؤمنين<span class="fm">(عليه السلام)</span>، وكان القائم بهذا المهم الطود الشامخ والعلم الجليل السيد الشريف محمد بن الحسين الرضي <span class="fm">(رضوان الله عليه)</span>.</p>

  <p>تميز هذا التطبيق بأمور .. منها:</p>

  <p><span class="quran">* الفهرست الموضوعي المتكامل.</span></p>

  <p><span class="quran">* الترجمة إلى الانجليزية.</span></p>

  <p><span class="quran">* أربع ترجمات إلى الفارسية.</span></p>

  <p><span class="quran">* شرح الكلمات الغامضة بما جاء في شرح المشايخ محمد عبده وصبحي صالح.</span></p>

  <p>إضافة إلى الميزات العامة من البحث والإشارات المرجعية التي لا تخلو منها التطبيقات.</p>

  <p>وفي الختام نهدي ثواب عملنا المتواضع هذا لروح الشهيد الشيخ حسين حمودي<span class="fm">(رحمه الله)</span> راجين من الله سبحانه أن يجعله ثواباً واصلاً، وعملاً مقبولاً، إنه أرحم الراحمين.</p>

  <p class="center">فريق مساحة حرة</p>
</body>
                  ''',
                    style: {
                      ...StyleHelper.getStyles(context)
                    },
                  ),
                ),
              ),
            ),
          ),

          // Bottom section with website and email
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text('الفاتحة لروح الشهيد الشيخ حسين حمودي (رحمه الله)'),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Email
                      InkWell(
                        onTap: () async {
                          try {
                            final Uri emailUri = Uri(
                              scheme: 'mailto',
                              path: 'info@masaha.org',
                            );
                            if (await canLaunchUrl(emailUri)) {
                              await launchUrl(emailUri);
                            } else {
                              // Fallback: try to launch with a different approach
                              final fallbackUri = Uri.parse('mailto:info@masaha.org');
                              await launchUrl(fallbackUri);
                            }
                          } catch (e) {
                            // Handle error silently or show a snackbar
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('لا يمكن فتح تطبيق البريد الإلكتروني')),
                              );
                            }
                          }
                        },
                        child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.alternate_email_rounded,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 24,)
                        ),
                      ),

                      // Website
                      InkWell(
                        onTap: () async {
                          try {
                            final Uri websiteUri = Uri.parse('https://masaha.org');
                            if (await canLaunchUrl(websiteUri)) {
                              await launchUrl(
                                websiteUri,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              // Fallback: try without external application mode
                              await launchUrl(websiteUri);
                            }
                          } catch (e) {
                            // Handle error silently or show a snackbar
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('لا يمكن فتح الموقع الإلكتروني')),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset('assets/icon/logo.svg', color: Theme.of(context).colorScheme.onSurface, height: 24, width: 24,)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
}
