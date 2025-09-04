import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/kundlichartModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class BasicDetailsWidget extends StatelessWidget {
  final String name;
  final String gender;
  final String birthDate;
  final String birthTime;
  final String? pdfLink;
  final String? timezone;
  final String? birthplace;
  final Panchang? panchang;

  const BasicDetailsWidget({
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.birthTime,
    required this.birthplace,
    required this.timezone,
    this.pdfLink,
    this.panchang,
    super.key,
  });
  String _formatBirthDate(String birthDate) {
    try {
      final dateTime = DateTime.parse(birthDate);
      final dateFormat = DateFormat('yyyy-MM-dd');
      return dateFormat.format(dateTime);
    } catch (e) {
      return birthDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a list of details for easy rendering
    final List<Map<String, String?>> details = [
      {'label': 'Name', 'value': name},
      {'label': 'Gender', 'value': gender},
      {'label': 'Birth Date', 'value': _formatBirthDate(birthDate)},
      {'label': 'Birth Time', 'value': birthTime},
      {'label': 'Birth Place', 'value': birthplace},
      {'label': 'Timezone', 'value': timezone},
    ];

    final List<Map<String, String?>> panchangDetailsList = [
      {'label': 'Ayanamsa name', 'value': panchang?.ayanamsaName},
      {'label': 'Day of birth', 'value': panchang?.dayOfBirth},
      {'label': 'Day Lord', 'value': panchang?.dayLord},
      {'label': 'Karna', 'value': panchang?.karana},
      {'label': 'Sunset at birth', 'value': panchang?.sunsetAtBirth},
      {'label': 'Sunrise at birth', 'value': panchang?.sunriseAtBirth},
      {'label': 'yoga', 'value': panchang?.yoga},
      {'label': 'tithi', 'value': panchang?.tithi},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100.w,
              height: 6.h,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text('Birth Details',
                  style:
                      Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                            color: Colors.black,
                          )),
            ),
            ListView.separated(
              shrinkWrap: true,
              primary: false,
              separatorBuilder: (context, index) => const SizedBox(height: 2.0),
              itemCount: details.length,
              itemBuilder: (context, index) {
                final detail = details[index];
                final isEven = index % 2 == 0;

                return Container(
                  color: isEven ? Colors.grey[200] : Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${detail['label']}:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        detail['value'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              width: 100.w,
              height: 6.h,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text('Panchang',
                  style:
                      Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                            color: Colors.black,
                          )),
            ),
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              primary: false,
              separatorBuilder: (context, index) => const SizedBox(height: 2.0),
              itemCount: panchangDetailsList.length,
              itemBuilder: (context, index) {
                final detail = panchangDetailsList[index];
                final isEven = index % 2 == 0;

                return Container(
                  color: isEven ? Colors.grey[200] : Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${detail['label']}:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        detail['value'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
