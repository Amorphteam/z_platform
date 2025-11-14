import 'package:flutter/material.dart';

class PageJumpDialog {
  const PageJumpDialog._();

  static Future<int?> show({
    required BuildContext context,
    required int totalPages,
  }) async {
    if (totalPages <= 0) return null;

    final formKey = GlobalKey<FormState>();
    final textController = TextEditingController();

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: textController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'أدخل رقم الصفحة (بين 1 و $totalPages)',
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال رقم الصفحة';
                }
                final latinValue = _convertArabicToLatin(value);
                final pageNumber = int.tryParse(latinValue);
                if (pageNumber == null ||
                    pageNumber <= 0 ||
                    pageNumber > totalPages) {
                  return ' الرقم يجب أن يكون بين ١ و $totalPages';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                if (formKey.currentState!.validate()) {
                  final latinValue = _convertArabicToLatin(value);
                  final pageNumber = int.tryParse(latinValue);
                  if (pageNumber != null) {
                    Navigator.of(dialogContext).pop(pageNumber - 1);
                  }
                }
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'إلغاء',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                'انتقل',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final latinValue = _convertArabicToLatin(textController.text);
                  final pageNumber = int.tryParse(latinValue);
                  if (pageNumber != null) {
                    Navigator.of(dialogContext).pop(pageNumber - 1);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );

    return result;
  }

  static String _convertArabicToLatin(String input) {
    const arabicToLatin = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    String result = input;
    arabicToLatin.forEach((arabic, latin) {
      result = result.replaceAll(arabic, latin);
    });
    return result;
  }
}

