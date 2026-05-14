import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cache_policy.dart';

final cachePolicyProvider = Provider<CachePolicy>((ref) => const CachePolicy());
