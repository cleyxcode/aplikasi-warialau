import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_apps_sd/core/constants/app_colors.dart';

void main() {
  test('App smoke colors are defined', () {
    expect(AppColors.primary.value, isNonZero);
    expect(AppColors.gold.value, isNonZero);
  });
}
