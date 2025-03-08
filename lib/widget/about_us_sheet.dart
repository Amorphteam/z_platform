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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48), // For balance
                    Text(
                      'حول التطبيق',
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
  <center style="color: #4CAF50; text-align: center;">بسم الله الرحمن الرحيم</center>
  <p>قد اجتهد الماضون من علمائنا<span class="fm">(رضوان الله عليهم)</span> على مر العصور في حفظ السنة الشريفة المتمثلة بأحاديث النبي الأعظم وأهل بيته الكرام<span class="fm">(عليهم السلام)</span> والتي تشكل ثاني مصادر التشريع بعد القرآن الكريم.</p>

  <p>أجل قد أتعبوا أبدانهم وصرفوا النفيس من أعمارهم في البحث والتنقيب والتمحيص والترتيب لتلك الأحاديث، حتى جمعت ودونت في موسوعات وأصبحت سهلة المنال لمن يريد أن ينهل من نميرها العذب.</p>

  <p>ومن أفضل الموسوعات التي صنفت في هذا المجال هو كتاب «وسائل الشيعة لتحصيل مسائل الشريعة» للمحدث الكبير والفقيه الجليل الشيخ الحر العاملي(قدس سره)، حيث جمع بين دفتيه ما يزيد على ثلاثين ألف حديث في فروع الدين.</p>

  <p>وقد أضافت إلى جماله جمالاً مؤسسة آل البيت<span class="fm">(عليهم السلام)</span> الموقرة إذ أخرجته بحلة جميلة وتحقيق رائع.</p>

  <p>ونحن بدورنا وتتميماً لتلك الجهود المباركة قمنا بانتاج هذا التطبيق الذي يشتمل على هذا الكتاب بتنسيق جيد وعرض رائع وميزات فريدة.</p>

  <p>ثم لما كان لسند الحديث ومعرفة حال الرواة الدور الأساسي في قبول الحديث ورفضه، ولما كانت موسوعة معجم رجال الحديث التي سطرها مرجع الطائفة الراحل آية الله العظمى السيد الخوئي<span class="fm">(قدس سره)</span> خاتمة ما كتب في عصرنا الحاضر في مجال علم الرجال، عملنا جاهدين على ربط رجال السند لكل حديث بما ورد في هذا المعجم، حتى أصبح بنقرة واحدة على اسم راوي في سلسلة السند ينتقل التطبيق مباشرة إلى واجهة يظهر فيها ما ورد عنه في المعجم.</p>

  <p>ولا يفوتنا التنويه إلى أن هناك النزر القليل من الرواة لم يتم ربطهم بسبب عدم عثورنا عليهم في معجم رجال الحديث.</p>

  <p>إضافة إلى هذه الميزة الفريدة في التطبيق هناك ميزات أخرى نقدمها لكم ..</p>

  <p>• الفهرسة السهلة والسريعة.</p>

  <p>• البحث السريع والدقيق مع قابلية تحديد مجال البحث.</p>

  <p>• إشارات مرجعية لكل صفحة.</p>

  <p>• تحريك كامل لنص الأحاديث.</p>

  <p>وفي الختام نسأل الله سبحانه أن يجعله خالصاً لوجهه الكريم وأن يجزل ثوابنا يوم نلقاه يوم لا ينفع مال ولابنون.</p>

  <p>نتطور بملاحظاتكم..</p>

   <center style="color: #4CAF50; text-align: center;">
فريق مساحة حرة</center>                  ''',
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        fontFamily: "font1",
                        padding: HtmlPaddings.all(16),
                      ),
                      "center": Style(
                          fontWeight: FontWeight.bold,
                          padding: HtmlPaddings.all(16),
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
                        textAlign: TextAlign.justify,
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
