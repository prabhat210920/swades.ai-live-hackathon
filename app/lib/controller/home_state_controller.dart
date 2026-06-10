import 'package:flutter_riverpod/flutter_riverpod.dart';

// Holds the current text from the search bar
final venueSearchQueryProvider = StateProvider<String>((ref) => '');

// Holds the currently selected category (default is 'All')
final venueCategoryProvider = StateProvider<String>((ref) => 'All');
