class CachePolicy {
  const CachePolicy({this.ttl = const Duration(minutes: 30)});

  final Duration ttl;

  bool isFresh(DateTime cachedAt, {DateTime? now}) {
    return (now ?? DateTime.now()).difference(cachedAt) < ttl;
  }
}
