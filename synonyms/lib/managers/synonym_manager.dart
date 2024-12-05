class SynonymManager {
  final Map<String, Set<String>> _synonymMap = {};

  void addSynonym(String word1, String word2) {
    final visited = <String, Set<String>>{};
    _addPair(word1, word2);
    _addPair(word2, word1);
    _applyTransitiveRule(word1, word2, visited);
  }

  void _addPair(String word, String synonym) {
    if (!_synonymMap.containsKey(word)) {
      _synonymMap[word] = {};
    }
    _synonymMap[word]?.add(synonym);
  }

  void _applyTransitiveRule(String word1, String word2, Map<String, Set<String>> visited) {
    if (visited.containsKey(word1) && visited[word1]!.contains(word2)) {
      return;
    }

    visited.putIfAbsent(word1, () => {}).add(word2);

    Set<String> newSynonyms = Set.from(_synonymMap[word2] ?? {});
    for (var synonym in newSynonyms) {
      if (synonym != word1) {
        _addPair(word1, synonym);
        _addPair(synonym, word1);
        _applyTransitiveRule(word1, synonym, visited);
      }
    }
  }

  Set<String> getSynonyms(String word) {
    return _synonymMap[word] ?? {};
  }

  Set<String> getAllWords() {
    return _synonymMap.keys.toSet();
  }
}
