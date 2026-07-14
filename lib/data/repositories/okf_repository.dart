import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../models/okf_concept.dart';

class OkfRepository {
  final Map<String, OkfConcept> _conceptCache = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  
  // Scans and parses local assets configured in pubspec
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // In Flutter, AssetManifest.json list all assets compiled in the application
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      // Select files under assets/okf/ that are markdown but not root indexes or logs
      final okfAssetPaths = manifestMap.keys.where((path) => 
        path.startsWith('assets/okf/') && path.endsWith('.md') && 
        !path.endsWith('index.md') && !path.endsWith('log.md')
      );

      for (final assetPath in okfAssetPaths) {
        final content = await rootBundle.loadString(assetPath);
        final concept = OkfConcept.fromMarkdown(content);
        
        // Match by UID, or generate one from the file path if missing
        final uid = concept.uid ?? assetPath
            .replaceAll('assets/okf/', '')
            .replaceAll('.md', '')
            .replaceAll('/', '_');
            
        _conceptCache[uid] = concept;
      }
      
      _isInitialized = true;
      print('✅ OkfRepository initialized with ${_conceptCache.length} concepts.');
    } catch (e) {
      print('⚠️ Error initializing OkfRepository: $e');
    }
  }

  // Get a concept by its unique identifier (e.g. 'lore_npcs_grizzled_warrior')
  OkfConcept? getConcept(String uid) {
    return _conceptCache[uid];
  }

  // Returns all parsed concepts
  List<OkfConcept> getAllConcepts() {
    return _conceptCache.values.toList();
  }

  // Simple Graph Traversal: Find all concepts linked inside a concept's markdown body
  List<OkfConcept> getLinkedConcepts(OkfConcept source) {
    final links = <OkfConcept>[];
    // Match standard Markdown links: [title](/path/to/node)
    final linkRegex = RegExp(r'\[.*?\]\((.*?)\)');
    final matches = linkRegex.allMatches(source.markdownBody);
    
    for (final match in matches) {
      final pathLink = match.group(1);
      if (pathLink != null) {
        // Normalize path link (e.g. /lore/sectors/neon_bastion_4 -> lore_sectors_neon_bastion_4)
        final normalizedLink = pathLink
            .replaceAll(RegExp(r'^\/'), '')
            .replaceAll('/', '_');
            
        // Look up in cache
        for (final entry in _conceptCache.entries) {
          if (entry.key.endsWith(normalizedLink) || normalizedLink.endsWith(entry.key)) {
            links.add(entry.value);
            break;
          }
        }
      }
    }
    return links;
  }
}
