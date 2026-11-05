import '../database/database.dart';

/// Categories arranged as top-level categories with their subcategories
/// (one level deep). A subcategory whose parent no longer exists is treated
/// as top level.
class CategoryTree {
  CategoryTree(List<Category> categories)
    : byId = {for (final c in categories) c.id: c} {
    final sorted = [...categories]..sort((a, b) => a.id.compareTo(b.id));
    for (final c in sorted) {
      final parent = _parentOf(c);
      if (parent == null) {
        roots.add(c);
      } else {
        (_children[parent.id] ??= []).add(c);
      }
    }
  }

  final Map<int, Category> byId;

  /// Top-level categories, oldest first.
  final List<Category> roots = [];
  final Map<int, List<Category>> _children = {};

  Category? _parentOf(Category c) {
    final pid = c.parentId;
    if (pid == null || pid == c.id) return null;
    final p = byId[pid];
    // Only one level: a parent that is itself a subcategory doesn't count.
    if (p == null || (p.parentId != null && byId.containsKey(p.parentId))) {
      return null;
    }
    return p;
  }

  /// Subcategories of [id], oldest first.
  List<Category> childrenOf(int id) => _children[id] ?? const [];

  bool hasChildren(int id) => childrenOf(id).isNotEmpty;

  /// The parent of [c], or null when [c] is top level.
  Category? parentOf(Category c) => _parentOf(c);

  bool isSub(Category c) => _parentOf(c) != null;

  /// The top-level category [id] rolls up into (itself when top level).
  int rootIdOf(int id) {
    final c = byId[id];
    if (c == null) return id;
    return _parentOf(c)?.id ?? id;
  }

  /// "Food › Restaurants" for a subcategory, the plain name otherwise.
  String pathName(Category c) {
    final p = _parentOf(c);
    return p == null ? c.name : '${p.name} › ${c.name}';
  }

  /// [c] renamed to its [pathName], for tags that show one category.
  Category withPathName(Category c) =>
      isSub(c) ? c.copyWith(name: pathName(c)) : c;

  /// Every category, each top-level one followed by its subcategories.
  List<Category> get ordered => [
    for (final r in roots) ...[r, ...childrenOf(r.id)],
  ];

  /// Rolls per-category [spent] (keyed by the matched category) up into
  /// top-level totals.
  Map<int, double> rollUp(Map<int, double> spent) {
    final out = <int, double>{};
    spent.forEach((id, v) {
      final root = rootIdOf(id);
      out[root] = (out[root] ?? 0) + v;
    });
    return out;
  }
}
