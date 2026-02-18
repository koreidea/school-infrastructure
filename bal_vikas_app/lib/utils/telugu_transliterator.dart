/// Transliterates English/Latin text to Telugu script.
///
/// Handles common Indian name patterns. If text already contains Telugu
/// characters, it is returned as-is.
class TeluguTransliterator {
  static const _virama = '\u0C4D'; // ్

  // Independent vowels (used at start of word or after another vowel)
  static const _vowels = <String, String>{
    'aa': 'ఆ',
    'ai': 'ఐ',
    'au': 'ఔ',
    'ee': 'ఈ',
    'oo': 'ఊ',
    'ou': 'ఔ',
    'a': 'అ',
    'i': 'ఇ',
    'u': 'ఉ',
    'e': 'ఎ',
    'o': 'ఒ',
  };

  // Vowel matras (dependent, used after a consonant)
  static const _matras = <String, String>{
    'aa': '\u0C3E', // ా
    'ai': '\u0C48', // ై
    'au': '\u0C4C', // ౌ
    'ee': '\u0C40', // ీ
    'oo': '\u0C42', // ూ
    'ou': '\u0C4C', // ౌ
    'a': '', // inherent vowel — no matra
    'i': '\u0C3F', // ి
    'u': '\u0C41', // ు
    'e': '\u0C46', // ె
    'o': '\u0C4A', // ొ
  };

  // Consonants (longest match first in the search order)
  static const _consonants = <String, String>{
    'shh': 'ష',
    'chh': 'ఛ',
    'sh': 'శ',
    'ch': 'చ',
    'th': 'థ',
    'dh': 'ధ',
    'bh': 'భ',
    'ph': 'ఫ',
    'gh': 'ఘ',
    'kh': 'ఖ',
    'jh': 'ఝ',
    'ng': 'ంగ',
    'nk': 'ంక',
    'k': 'క',
    'g': 'గ',
    'j': 'జ',
    'c': 'క',
    'q': 'క',
    't': 'త',
    'd': 'ద',
    'n': 'న',
    'p': 'ప',
    'b': 'బ',
    'm': 'మ',
    'y': 'య',
    'r': 'ర',
    'l': 'ల',
    'v': 'వ',
    'w': 'వ',
    's': 'స',
    'h': 'హ',
    'f': 'ఫ',
    'z': 'జ',
    'x': 'క\u0C4Dస', // క్స
  };

  /// Returns true if [text] already contains Telugu script characters.
  static bool _isAlreadyTelugu(String text) {
    for (final c in text.runes) {
      if (c >= 0x0C00 && c <= 0x0C7F) return true;
    }
    return false;
  }

  /// Transliterate [text] from English to Telugu script.
  /// Words that are already in Telugu or contain digits are left unchanged.
  static String transliterate(String text) {
    if (text.isEmpty) return text;
    if (_isAlreadyTelugu(text)) return text;

    // Process word by word to preserve spaces and punctuation
    final result = StringBuffer();
    final wordPattern = RegExp(r"[a-zA-Z]+|[^a-zA-Z]+");
    for (final match in wordPattern.allMatches(text)) {
      final word = match.group(0)!;
      if (RegExp(r'^[a-zA-Z]+$').hasMatch(word)) {
        result.write(_transliterateWord(word));
      } else {
        result.write(word); // keep spaces, digits, punctuation as-is
      }
    }
    return result.toString();
  }

  static String _transliterateWord(String word) {
    final buf = StringBuffer();
    final lower = word.toLowerCase();
    int i = 0;
    bool lastWasConsonant = false;

    while (i < lower.length) {
      // --- Try vowel match ---
      String? matchedVowel;
      // Try length 2, then 1
      for (final len in [2, 1]) {
        if (i + len > lower.length) continue;
        final sub = lower.substring(i, i + len);
        if (lastWasConsonant) {
          if (_matras.containsKey(sub)) {
            matchedVowel = sub;
            break;
          }
        } else {
          if (_vowels.containsKey(sub)) {
            matchedVowel = sub;
            break;
          }
        }
      }

      if (matchedVowel != null) {
        if (lastWasConsonant) {
          buf.write(_matras[matchedVowel]!);
        } else {
          buf.write(_vowels[matchedVowel]!);
        }
        i += matchedVowel.length;
        lastWasConsonant = false;
        continue;
      }

      // --- Try consonant match ---
      String? matchedConsonant;
      for (final len in [3, 2, 1]) {
        if (i + len > lower.length) continue;
        final sub = lower.substring(i, i + len);
        if (_consonants.containsKey(sub)) {
          matchedConsonant = sub;
          break;
        }
      }

      if (matchedConsonant != null) {
        if (lastWasConsonant) {
          // Previous consonant had no vowel → add virama (halant)
          buf.write(_virama);
        }
        buf.write(_consonants[matchedConsonant]!);
        i += matchedConsonant.length;
        lastWasConsonant = true;
        continue;
      }

      // --- Unrecognized character ---
      if (lastWasConsonant) {
        buf.write(_virama);
      }
      buf.write(word[i]);
      i++;
      lastWasConsonant = false;
    }

    // Trailing consonant at end of word → add virama
    if (lastWasConsonant) {
      buf.write(_virama);
    }

    return buf.toString();
  }
}

/// Convenience function for transliterating to Telugu.
String toTelugu(String text) => TeluguTransliterator.transliterate(text);
