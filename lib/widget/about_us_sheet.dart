import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class AboutUsSheet extends StatelessWidget {
  const AboutUsSheet({super.key});

  @override
  Widget build(BuildContext context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // For balance
                  Text(
                    'عن التطبيق',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Html(
                  data: '''
                    <div dir="rtl">
                      <h1 style="color: #4CAF50; text-align: center;">مرحباً بكم في تطبيق الحديث الشريف</h1>
                      
                      <h2 style="color: #2196F3;">عن التطبيق</h2>
                      <p>تطبيق الحديث الشريف هو مصدر شامل للوصول إلى الأحاديث النبوية الشريفة. يوفر التطبيق واجهة سهلة الاستخدام للبحث في مجموعة واسعة من الأحاديث.</p>
                      
                      <h2 style="color: #2196F3;">المميزات الرئيسية</h2>
                      <ul>
                        <li>بحث متقدم في الأحاديث</li>
                        <li>إمكانية حفظ الإشارات المرجعية</li>
                        <li>سجل القراءة</li>
                        <li>واجهة مستخدم سهلة وبسيطة</li>
                      </ul>
                      
                      <h2 style="color: #2196F3;">المصادر</h2>
                      <p>يتم جمع الأحاديث من مصادر موثوقة ومتعددة، مع التأكد من صحة كل حديث.</p>
                      
                      <h2 style="color: #2196F3;">تواصل معنا</h2>
                      <p>نرحب بملاحظاتكم وآرائكم في تطوير التطبيق. يمكنكم التواصل معنا عبر:</p>
                      <ul>
                        <li>البريد الإلكتروني: example@email.com</li>
                        <li>موقعنا الإلكتروني: www.example.com</li>
                      </ul>
                      
                      <p style="text-align: center; color: #666;">جميع الحقوق محفوظة © 2024</p>
                    </div>
                  ''',
                  style: {
                    "body": Style(
                      fontSize: FontSize(16),
                      fontFamily: "Cairo",
                      padding: HtmlPaddings.all(16),
                      textAlign: TextAlign.right,
                    ),
                    "h1": Style(
                      fontSize: FontSize(24),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(bottom: 16),
                      textAlign: TextAlign.center,
                    ),
                    "h2": Style(
                      fontSize: FontSize(20),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(top: 24, bottom: 8),
                      textAlign: TextAlign.right,
                    ),
                    "p": Style(
                      margin: Margins.only(bottom: 16),
                      lineHeight: LineHeight(1.5),
                      textAlign: TextAlign.right,
                    ),
                    "ul": Style(
                      margin: Margins.only(bottom: 16),
                      padding: HtmlPaddings.only(right: 24),
                    ),
                    "li": Style(
                      margin: Margins.only(bottom: 8),
                      textAlign: TextAlign.right,
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
} 