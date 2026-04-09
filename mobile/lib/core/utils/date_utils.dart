import 'package:intl/intl.dart';

class DateUtilsHelper {
  static final DateFormat _apiFormatter = DateFormat('yyyy-MM-dd');

  static String toApi(DateTime date) {
    return _apiFormatter.format(date);
  }
}
