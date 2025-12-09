import 'package:flutter/material.dart';

bool isDesktop(BuildContext context) {
  return MediaQuery.of(context).size.width > desktopSmall;
}

bool isTablet(BuildContext context) {
  return MediaQuery.of(context).size.width > tabletNormal;
}

bool isSmollTable(BuildContext context) {
  return MediaQuery.of(context).size.width > tabletSmall;
}

//Mobile size
double get mobileSmall => 320;

double get mobileNormal => 375;

double get mobileLarge => 414;

double get mobileExtraLarge => 480;

//table size
double get tabletSmall => 600;

double get tabletNormal => 768;

double get tabletLarge => 800;

//desktop size
double get desktopSmall => 900;

double get desktopMedium => 1280;

double get desktopNormal => 1920;

double get desktopLarge => 3840;

double get desktopExtraLarge => 4096;
