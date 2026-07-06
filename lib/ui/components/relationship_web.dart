import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/portal_theme.dart';
import '../../ui/animations/spring_tap_wrapper.dart';
import '../../ui/components/glass_card.dart';

class FactionNode {
  final String id;
  final String name;
  final String description;
  final Color color;
  final double x; // Relative X coordinate (0.0 to 1.0)
  final double y; // Relative Y coordinate (0.0 to 1.0)
  final int activeCharacters;
  final String currentGoal;

  const FactionNode({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.x,
    required this.y,
    required this.activeCharacters,
    required this.currentGoal,
  });
}

class FactionRelation {
  final String sourceId;
  final String targetId;
  final String status;
  final String description;
  final Color color;
  final bool isDashed;

  const FactionRelation({
    required this.sourceId,
    required this.targetId,
    required this.status,
    required this.description,
    required this.color,
    this.isDashed = false,
  });
}

class FactionInfluenceBoard extends StatefulWidget {
  const FactionInfluenceBoard({super.key});

  @override
  State<FactionInfluenceBoard> createState() => _FactionInfluenceBoardState();
}

class _FactionInfluenceBoardState extends State<FactionInfluenceBoard> {
  FactionNode? _selectedNode;
  FactionRelation? _selectedRelation;

  final List<FactionNode> _nodes = const [
    FactionNode(
      id: 'aethelgard',
      name: 'Aethelgard Alliance',
      description: 'A sovereign dominion focused on imperial hierarchy, historical continuity, and celestial order.',
      color: Color(0xFFFFD700), // Gold
      x: 0.5,
      y: 0.2,
      activeCharacters: 12,
      currentGoal: 'Defending border coordinates',
    ),
    FactionNode(
      id: 'elysium',
      name: 'Elysium Syndicate',
      description: 'A shadowy alliance of merchants, chroniclers, and temporal rogue squads operating in the obsidian gaps.',
      color: Color(0xFFB388FF), // Violet
      x: 0.2,
      y: 0.7,
      activeCharacters: 9,
      currentGoal: 'Unlocking ancient memory caches',
    ),
    FactionNode(
      id: 'vanguard',
      name: 'Vanguard Order',
      description: 'A military protectorate of timeline wardens guarding the Sanctuary Core and enforcing laws of causality.',
      color: Color(0xFF66BB6A), // Moss Green
      x: 0.8,
      y: 0.7,
      activeCharacters: 7,
      currentGoal: 'Burying temporal desync flares',
    ),
  ];

  final List<FactionRelation> _relations = const [
    FactionRelation(
      sourceId: 'aethelgard',
      targetId: 'elysium',
      status: 'COLD WAR',
      description: 'Hostile tension over disputed archives. Undergo silent spy skirmishes at borders.',
      color: PortalTheme.alertTerracotta,
      isDashed: true,
    ),
    FactionRelation(
      sourceId: 'elysium',
      targetId: 'vanguard',
      status: 'PRAGMATIC TRUCE',
      description: 'Mutual non-interference treaty regarding trade routes through the timeline core.',
      color: PortalTheme.tealNavyAccent,
    ),
    FactionRelation(
      sourceId: 'vanguard',
      targetId: 'aethelgard',
      status: 'PEACE ACCORD',
      description: 'Mutual defense covenant protecting the Sanctuary Core from external memory decay.',
      color: Color(0xFF66BB6A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHRONICLE RELATIONSHIP WEBS',
                style: PortalTheme.statsText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: PortalTheme.infoSlate,
                ),
              ),
              Text(
                'ERA 3 STATUS',
                style: PortalTheme.statsText.copyWith(
                  color: PortalTheme.successMoss,
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            'Interactive narrative nodes showing faction alignment and active alignments.',
            style: PortalTheme.bodyText,
          ),
          const SizedBox(height: 24.0),
          
          // Map Canvas
          AspectRatio(
            aspectRatio: 1.8,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return GestureDetector(
                  onTapUp: (details) {
                    final localPos = details.localPosition;
                    
                    // Hit test nodes
                    FactionNode? tappedNode;
                    for (final node in _nodes) {
                      final nx = node.x * width;
                      final ny = node.y * height;
                      final dist = math.sqrt(math.pow(localPos.dx - nx, 2) + math.pow(localPos.dy - ny, 2));
                      if (dist <= 28.0) {
                        tappedNode = node;
                        break;
                      }
                    }

                    if (tappedNode != null) {
                      setState(() {
                        _selectedNode = tappedNode;
                        _selectedRelation = null;
                      });
                      return;
                    }

                    // Hit test relations (midpoints)
                    FactionRelation? tappedRelation;
                    for (final rel in _relations) {
                      final s = _nodes.firstWhere((n) => n.id == rel.sourceId);
                      final t = _nodes.firstWhere((n) => n.id == rel.targetId);
                      
                      final sx = s.x * width;
                      final sy = s.y * height;
                      final tx = t.x * width;
                      final ty = t.y * height;

                      final mx = (sx + tx) / 2;
                      final my = (sy + ty) / 2;

                      final dist = math.sqrt(math.pow(localPos.dx - mx, 2) + math.pow(localPos.dy - my, 2));
                      if (dist <= 24.0) {
                        tappedRelation = rel;
                        break;
                      }
                    }

                    setState(() {
                      _selectedRelation = tappedRelation;
                      _selectedNode = null;
                    });
                  },
                  child: CustomPaint(
                    painter: _InfluenceGraphPainter(
                      nodes: _nodes,
                      relations: _relations,
                      selectedNode: _selectedNode,
                      selectedRelation: _selectedRelation,
                    ),
                    child: Container(),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24.0),
          
          // Selection Details Sheet
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildDetailsPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel() {
    if (_selectedNode != null) {
      final node = _selectedNode!;
      return Container(
        key: ValueKey('node_${node.id}'),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: PortalTheme.lightGraySurface.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: node.color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  node.name.toUpperCase(),
                  style: PortalTheme.subsectionHeader.copyWith(color: node.color),
                ),
                Text(
                  '${node.activeCharacters} ACTIVE MEMBERS',
                  style: PortalTheme.statsText,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              node.description,
              style: PortalTheme.smallText.copyWith(height: 1.5),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Text(
                  'ACTIVE OBJECTIVE: ',
                  style: PortalTheme.statsText.copyWith(fontSize: 10.0, color: PortalTheme.infoSlate),
                ),
                Text(
                  node.currentGoal.toUpperCase(),
                  style: PortalTheme.statsText.copyWith(fontSize: 10.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_selectedRelation != null) {
      final rel = _selectedRelation!;
      final s = _nodes.firstWhere((n) => n.id == rel.sourceId);
      final t = _nodes.firstWhere((n) => n.id == rel.targetId);

      return Container(
        key: ValueKey('rel_${rel.sourceId}_${rel.targetId}'),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: PortalTheme.lightGraySurface.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: rel.color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${s.name.split(' ')[0]} ⇄ ${t.name.split(' ')[0]} ALIGNMENT',
                  style: PortalTheme.statsText.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: rel.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    rel.status,
                    style: PortalTheme.statsText.copyWith(
                      color: rel.color,
                      fontSize: 9.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              rel.description,
              style: PortalTheme.smallText.copyWith(height: 1.5),
            ),
          ],
        ),
      );
    }

    return Container(
      key: const ValueKey('empty'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: Text(
          'TAP FACTION NODES OR RELATIONS TO INSPECT DIRECTIVES',
          style: PortalTheme.statsText.copyWith(
            fontSize: 10.0,
            color: PortalTheme.warmGrayBodyText,
          ),
        ),
      ),
    );
  }
}

class _InfluenceGraphPainter extends CustomPainter {
  final List<FactionNode> nodes;
  final List<FactionRelation> relations;
  final FactionNode? selectedNode;
  final FactionRelation? selectedRelation;

  const _InfluenceGraphPainter({
    required this.nodes,
    required this.relations,
    this.selectedNode,
    this.selectedRelation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 1. Draw Connection Lines (Relations)
    for (final rel in relations) {
      final s = nodes.firstWhere((n) => n.id == rel.sourceId);
      final t = nodes.firstWhere((n) => n.id == rel.targetId);

      final sx = s.x * width;
      final sy = s.y * height;
      final tx = t.x * width;
      final ty = t.y * height;

      final isSelected = selectedRelation == rel;

      final paint = Paint()
        ..color = isSelected ? rel.color : rel.color.withValues(alpha: 0.4)
        ..strokeWidth = isSelected ? 3.0 : 1.5
        ..style = PaintingStyle.stroke;

      if (rel.isDashed) {
        _drawDashedLine(canvas, Offset(sx, sy), Offset(tx, ty), paint);
      } else {
        canvas.drawLine(Offset(sx, sy), Offset(tx, ty), paint);
      }

      // Draw middle status badge background helper
      final mx = (sx + tx) / 2;
      final my = (sy + ty) / 2;
      
      final badgePaint = Paint()
        ..color = isSelected ? PortalTheme.lightGraySurface : PortalTheme.creamBg
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(mx, my), 8.0, badgePaint);
      
      final borderPaint = Paint()
        ..color = isSelected ? rel.color : rel.color.withValues(alpha: 0.3)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      
      canvas.drawCircle(Offset(mx, my), 8.0, borderPaint);
    }

    // 2. Draw Faction Nodes
    for (final node in nodes) {
      final nx = node.x * width;
      final ny = node.y * height;

      final isSelected = selectedNode == node;

      // Glow Ring
      final glowPaint = Paint()
        ..color = node.color.withValues(alpha: isSelected ? 0.3 : 0.1)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(nx, ny), isSelected ? 32.0 : 24.0, glowPaint);

      // Core Circle
      final corePaint = Paint()
        ..color = node.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(nx, ny), 10.0, corePaint);

      // Border outline ring
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: isSelected ? 0.8 : 0.4)
        ..strokeWidth = isSelected ? 2.5 : 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(nx, ny), 16.0, borderPaint);

      // Faction Name text overlay label
      final textSpan = TextSpan(
        text: node.name.split(' ')[0],
        style: TextStyle(
          color: isSelected ? Colors.white : PortalTheme.warmGrayBodyText,
          fontFamily: 'Jost',
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 10.0,
          letterSpacing: 1.0,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      // Offset text slightly under the node
      textPainter.paint(
        canvas,
        Offset(nx - textPainter.width / 2, ny + 20.0),
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 4.0;
    
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    var currentDist = 0.0;
    final cosVal = dx / distance;
    final sinVal = dy / distance;
    
    while (currentDist < distance) {
      final x1 = start.dx + cosVal * currentDist;
      final y1 = start.dy + sinVal * currentDist;
      
      currentDist += dashWidth;
      final x2 = start.dx + cosVal * math.min(currentDist, distance);
      final y2 = start.dy + sinVal * math.min(currentDist, distance);
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      currentDist += dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _InfluenceGraphPainter oldDelegate) {
    return oldDelegate.selectedNode != selectedNode ||
        oldDelegate.selectedRelation != selectedRelation;
  }
}
