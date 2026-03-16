// Normalizes Polish diacritics so locale-aware A→Z order is preserved.
// Example: 'Łukasz' → 'lzukasz', sorts after 'Ludwik' → 'ludwik'.
String normalizeForSort(String s) => s
    .toLowerCase()
    .replaceAll('ą', 'az')
    .replaceAll('ć', 'cz')
    .replaceAll('ę', 'ez')
    .replaceAll('ł', 'lz')
    .replaceAll('ń', 'nz')
    .replaceAll('ó', 'oz')
    .replaceAll('ś', 'sz')
    .replaceAll('ź', 'zz')
    .replaceAll('ż', 'zz');
