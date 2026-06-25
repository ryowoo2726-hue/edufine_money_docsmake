import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui/services/update_service.dart';

void main() {
  test('compares release tag versions', () {
    expect(compareVersions('v0.1.1', '0.1.0'), greaterThan(0));
    expect(compareVersions('v0.1.0', '0.1.0'), 0);
    expect(compareVersions('v0.0.9', '0.1.0'), lessThan(0));
  });
}
