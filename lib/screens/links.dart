import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:akai/utils/device_utils.dart';

class HelpfulLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Helpful Links',
            style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ListView(
            children: <Widget>[
              ///Periods for kids
              _buildElevatedButton(
                title: 'All About Periods (For Kids)',
                url: 'https://kidshealth.org/en/kids/menstruation.html',
                icon: Iconsax.heart,
              ),

              ///Periods for Teens
              _buildElevatedButton(
                title: 'All About Periods (For Teens)',
                url: 'https://kidshealth.org/en/teens/menstruation.html',
                icon: Iconsax.heart,
              ),

              ///Your Menstrual Cycle
              _buildElevatedButton(
                title: 'Your Menstrual Cycle (FAQs)',
                url:
                    'https://www.womenshealth.gov/menstrual-cycle/your-menstrual-cycle',
                icon: Iconsax.health,
              ),

              ///Period Cramps
              _buildElevatedButton(
                title: 'Menstrual Cycle (Youtube Video)',
                url:
                    'https://www.youtube.com/watch?v=3PaswCBD9j0&ab_channel=5MinuteSchool',
                icon: Iconsax.video,
              ),

              ///Menstrual Cycle
              _buildElevatedButton(
                title: 'Period Cramps',
                url:
                    'https://www.mayoclinic.org/diseases-conditions/menstrual-cramps/diagnosis-treatment/drc-20374944',
                icon: Iconsax.health,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///Custom Buttons for links
  Widget _buildElevatedButton({
    required String title,
    required String url,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),

        //Using custom function
        onPressed: () => TDeviceUtils.launchUrl(url),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: Colors.white),
            SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4.0),
                  //Text(url, style: TextStyle(fontSize: 12.0)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
