import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../models/okf_models.dart';

/// Represents a parsed node in the OKF local graph.
class OKFNode {
  final String id;
  final String type;
  final String title;
  final String description;
  final String content;
  final List<String> tags;
  final List<String> dependencies;
  final Map<String, dynamic> rawFrontmatter;

  OKFNode({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.content,
    required this.tags,
    required this.dependencies,
    required this.rawFrontmatter,
  });
}

/// Explorer service that scans local assets/lore directory to load, index,
/// and traverse the OKF v0.1 narrative lore graph.
class OKFExplorerService {
  final String loreRootPath;
  final Map<String, OKFNode> _nodesCache = {};

  OKFExplorerService({required this.loreRootPath});

  /// Recursively scans the lore root directory and indexes all Markdown files.
  Future<void> reindexGraph() async {
    _nodesCache.clear();
    final directory = Directory(loreRootPath);
    if (!await directory.exists()) {
      debugPrint('Lore directory does not exist at path: $loreRootPath');
      return;
    }

    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is File && p.extension(entity.path).toLowerCase() == '.md') {
        final filename = p.basename(entity.path);
        // Exclude reserved filenames
        if (filename == 'index.md' || filename == 'log.md') continue;

        try {
          final content = await entity.readAsString();
          final node = _parseMarkdownNode(entity.path, content);
          if (node != null) {
            _nodesCache[node.id] = node;
          }
        } catch (e) {
          debugPrint('Error parsing OKF node file at ${entity.path}: $e');
        }
      }
    }
    debugPrint('OKF Graph Reindexed: Indexed ${_nodesCache.length} nodes.');
  }

  /// Parses an individual Markdown document separating YAML frontmatter from the body.
  OKFNode? _parseMarkdownNode(String filePath, String rawText) {
    // Relative path to serve as the unique ID (without extension)
    final relativePath = p.relative(filePath, from: loreRootPath);
    final id = p.withoutExtension(relativePath).replaceAll('\\', '/');

    final lines = rawText.split('\n');
    if (lines.isEmpty || lines.first.trim() != '---') {
      debugPrint('Invalid OKF file formatting. Missing starting yaml delimiter in $id');
      return null;
    }

    int yamlEndIndex = -1;
    for (int i = 1; i < lines.length; i++) {
      if (lines[i].trim() == '---') {
        yamlEndIndex = i;
        break;
      }
    }

    if (yamlEndIndex == -1) {
      debugPrint('Invalid OKF file formatting. Missing ending yaml delimiter in $id');
      return null;
    }

    final yamlBlock = lines.sublist(1, yamlEndIndex).join('\n');
    final bodyContent = lines.sublist(yamlEndIndex + 1).join('\n').trim();

    final frontmatter = _parseMiniYaml(yamlBlock);
    final type = frontmatter['type']?.toString() ?? 'Generic_Concept';
    final title = frontmatter['title']?.toString() ?? p.basename(id);
    final description = frontmatter['description']?.toString() ?? '';
    
    // Parse tags list
    List<String> tags = [];
    if (frontmatter['tags'] is List) {
      tags = List<String>.from(frontmatter['tags'] as List);
    } else if (frontmatter['tags'] is String) {
      tags = (frontmatter['tags'] as String)
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // Parse explicit dependencies
    List<String> dependencies = [];
    if (frontmatter['dependencies'] is List) {
      dependencies = List<String>.from(frontmatter['dependencies'] as List);
    } else if (frontmatter['dependencies'] is String) {
      dependencies = (frontmatter['dependencies'] as String)
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return OKFNode(
      id: id,
      type: type,
      title: title,
      description: description,
      content: bodyContent,
      tags: tags.map((t) => t.toLowerCase()).toList(),
      dependencies: dependencies,
      rawFrontmatter: frontmatter,
    );
  }

  /// Minimal Yaml parser designed to read flat keys and list structures
  Map<String, dynamic> _parseMiniYaml(String yamlText) {
    final Map<String, dynamic> result = {};
    final lines = yamlText.split('\n');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final colonIndex = line.indexOf(':');
      if (colonIndex == -1) continue;

      final key = line.substring(0, colonIndex).trim();
      var valueStr = line.substring(colonIndex + 1).trim();

      // Handle simple list format: [val1, val2]
      if (valueStr.startsWith('[') && valueStr.endsWith(']')) {
        final listVals = valueStr
            .substring(1, valueStr.length - 1)
            .split(',')
            .map((s) => s.trim())
            .map((s) => s.replaceAll('"', '').replaceAll("'", ""))
            .where((s) => s.isNotEmpty)
            .toList();
        result[key] = listVals;
      } else {
        // Strip quotes
        if ((valueStr.startsWith('"') && valueStr.endsWith('"')) ||
            (valueStr.startsWith("'") && valueStr.endsWith("'"))) {
          valueStr = valueStr.substring(1, valueStr.length - 1);
        }
        result[key] = valueStr;
      }
    }
    return result;
  }

  /// Traverses the OKF graph from a starting query using a Depth-Limited Search
  /// (DLS) algorithm bounded at depth d <= 2.
  /// 
  /// Bounded weight threshold >= 0.65 determines node inclusion.
  /// Edge weighting formula: W_ij = alpha * Jaccard(tags) + beta * Dependency + gamma * MarkdownLink
  Future<OKFQueryResult> queryLoreContext({
    required String startingNodeId,
    double alpha = 0.5,
    double beta = 0.3,
    double gamma = 0.2,
    double weightThreshold = 0.65,
  }) async {
    if (_nodesCache.isEmpty) {
      await reindexGraph();
    }

    final startNode = _nodesCache[startingNodeId];
    if (startNode == null) {
      debugPrint('Start node $startingNodeId not found in local OKF graph.');
      return const OKFQueryResult(chunks: [], relevanceScore: 0.0, citationSources: []);
    }

    final Map<String, double> scores = {startingNodeId: 1.0};
    final Set<String> visited = {startingNodeId};
    final List<OKFNode> resultNodes = [startNode];

    // BFS queue for Depth-Limited Search (Item, Depth)
    final List<MapEntry<String, int>> queue = [MapEntry(startingNodeId, 0)];

    while (queue.isNotEmpty) {
      final currentEntry = queue.removeAt(0);
      final currentId = currentEntry.key;
      final currentDepth = currentEntry.value;

      if (currentDepth >= 2) continue; // Boundary depth d <= 2

      final currentNode = _nodesCache[currentId]!;

      // Check all other nodes in the graph for potential edges
      for (final neighborNode in _nodesCache.values) {
        if (visited.contains(neighborNode.id)) continue;

        final weight = _calculateEdgeWeight(
          currentNode,
          neighborNode,
          alpha: alpha,
          beta: beta,
          gamma: gamma,
        );

        if (weight >= weightThreshold) {
          visited.add(neighborNode.id);
          scores[neighborNode.id] = weight;
          resultNodes.add(neighborNode);
          queue.add(MapEntry(neighborNode.id, currentDepth + 1));
        }
      }
    }

    // Convert to LoreChunks
    final chunks = resultNodes.map((node) {
      return LoreChunk(
        id: node.id,
        title: node.title,
        content: node.content,
        relevanceScore: scores[node.id] ?? 0.0,
        metadata: {
          'type': node.type,
          ...node.rawFrontmatter,
        },
      );
    }).toList();

    // Sort by relevance score descending
    chunks.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    final averageRelevance = chunks.isEmpty
        ? 0.0
        : chunks.map((c) => c.relevanceScore).reduce((a, b) => a + b) / chunks.length;

    final citations = resultNodes.map((n) => 'assets/lore/${n.id}.md').toList();

    return OKFQueryResult(
      chunks: chunks,
      relevanceScore: averageRelevance,
      citationSources: citations,
    );
  }

  /// Calculates the edge connection weight between two nodes based on tags,
  /// explicit dependencies, and Markdown cross-links.
  double _calculateEdgeWeight(
    OKFNode a,
    OKFNode b, {
    required double alpha,
    required double beta,
    required double gamma,
  }) {
    // 1. Tag Jaccard Similarity
    double jaccard = 0.0;
    if (a.tags.isNotEmpty || b.tags.isNotEmpty) {
      final setA = a.tags.toSet();
      final setB = b.tags.toSet();
      final intersection = setA.intersection(setB).length;
      final union = setA.union(setB).length;
      jaccard = intersection / union;
    }

    // 2. Explicit Dependencies
    double dependency = 0.0;
    if (b.dependencies.contains(a.id) || a.dependencies.contains(b.id)) {
      dependency = 1.0;
    }

    // 3. Markdown links
    double markdownLink = 0.0;
    // Check if B's content references A's link, or A references B
    final regexA = RegExp('\\[[^\\]]*\\]\\((?:\\/|\\.\\/)?${RegExp.escape(a.id)}(?:\\.md)?\\)');
    final regexB = RegExp('\\[[^\\]]*\\]\\((?:\\/|\\.\\/)?${RegExp.escape(b.id)}(?:\\.md)?\\)');

    if (regexA.hasMatch(b.content) || regexB.hasMatch(a.content)) {
      markdownLink = 1.0;
    }

    return (alpha * jaccard) + (beta * dependency) + (gamma * markdownLink);
  }
}

/// Provider exposing the local OKFExplorerService.
final okfExplorerServiceProvider = Provider<OKFExplorerService>((ref) {
  return OKFExplorerService(loreRootPath: p.join(Directory.current.path, 'assets', 'lore'));
});
