import 'package:yaml/yaml.dart';

class OkfConcept {
  final String type;
  final String? uid;
  final String? title;
  final String? description;
  final String? resource;
  final List<String> tags;
  final DateTime? timestamp;
  final Map<String, dynamic> attributes; // For additional properties (e.g. Compute_Power, environmental_stability)
  final String markdownBody;

  OkfConcept({
    required this.type,
    this.uid,
    this.title,
    this.description,
    this.resource,
    required this.tags,
    this.timestamp,
    required this.attributes,
    required this.markdownBody,
  });

  // Parses an OKF markdown document containing YAML frontmatter
  factory OkfConcept.fromMarkdown(String content) {
    // Matches --- yaml --- followed by markdown body
    final yamlPattern = RegExp(r'^---\s*\n(.*?)\n---\s*\n(.*)$', dotAll: true);
    final match = yamlPattern.firstMatch(content);

    if (match == null) {
      return OkfConcept(
        type: 'unknown',
        tags: [],
        attributes: {},
        markdownBody: content,
      );
    }

    final yamlText = match.group(1) ?? '';
    final body = match.group(2) ?? '';

    YamlMap? yamlMap;
    try {
      yamlMap = loadYaml(yamlText) as YamlMap?;
    } catch (e) {
      // Fallback if YAML parsing fails
    }

    if (yamlMap == null) {
      return OkfConcept(
        type: 'unknown',
        tags: [],
        attributes: {},
        markdownBody: body,
      );
    }

    final type = yamlMap['type']?.toString() ?? 'unknown';
    final uid = yamlMap['uid']?.toString() ?? yamlMap['id']?.toString();
    final title = yamlMap['title']?.toString();
    final description = yamlMap['description']?.toString();
    final resource = yamlMap['resource']?.toString();
    
    final tagsList = <String>[];
    if (yamlMap['tags'] is YamlList) {
      for (final item in yamlMap['tags'] as YamlList) {
        tagsList.add(item.toString());
      }
    }

    DateTime? timestamp;
    if (yamlMap['timestamp'] != null) {
      timestamp = DateTime.tryParse(yamlMap['timestamp'].toString());
    }

    // Capture all non-standard fields as additional attributes
    final attributes = <String, dynamic>{};
    yamlMap.forEach((key, value) {
      final keyStr = key.toString();
      if (!['type', 'uid', 'id', 'title', 'description', 'resource', 'tags', 'timestamp'].contains(keyStr)) {
        if (value is YamlMap) {
          attributes[keyStr] = Map<String, dynamic>.from(value);
        } else if (value is YamlList) {
          attributes[keyStr] = List<dynamic>.from(value);
        } else {
          attributes[keyStr] = value;
        }
      }
    });

    return OkfConcept(
      type: type,
      uid: uid,
      title: title,
      description: description,
      resource: resource,
      tags: tagsList,
      timestamp: timestamp,
      attributes: attributes,
      markdownBody: body,
    );
  }
}
