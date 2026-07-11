import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/portal_theme.dart';
import '../../services/debug_reports_service.dart';
import '../../ui/animations/spring_tap_wrapper.dart';
import '../../ui/components/glass_card.dart';
import '../../router/app_router.dart';

class GlobalFeedbackOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalFeedbackOverlay({super.key, required this.child});

  @override
  ConsumerState<GlobalFeedbackOverlay> createState() => _GlobalFeedbackOverlayState();
}

class _GlobalFeedbackOverlayState extends ConsumerState<GlobalFeedbackOverlay> with SingleTickerProviderStateMixin {
  final GlobalKey _repaintKey = GlobalKey();
  late AnimationController _cameraAnimController;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    // Cute breathing animation for the camera button
    _cameraAnimController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cameraAnimController.dispose();
    super.dispose();
  }

  Future<void> _captureAndShowFeedbackDialog() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // Give Flutter one frame to resolve layout
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('RepaintBoundary context not found.');
      }

      final image = await boundary.toImage(pixelRatio: 1.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert image to bytes.');
      }

      final pngBytes = byteData.buffer.asUint8List();
      final base64Image = base64Encode(pngBytes);

      final routePath = ref.read(routerProvider).routeInformationProvider.value.uri.path;

      if (mounted) {
        _showFeedbackDialog(base64Image, routePath);
      }
    } catch (e) {
      debugPrint('Failed to capture screenshot: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Screenshot capture failed: $e'),
            backgroundColor: PortalTheme.alertTerracotta,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _showFeedbackDialog(String base64Image, String routePath) {
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340.0),
                child: GlassCard(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TRANSMIT NARRATIVE FEEDBACK',
                        style: PortalTheme.statsText.copyWith(
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          color: PortalTheme.tealNavyAccent,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Report bugs or interface issues directly to the developer timeline.',
                        style: PortalTheme.smallText.copyWith(color: PortalTheme.warmGrayBodyText),
                      ),
                      const SizedBox(height: 16.0),

                      // Screen Capture Thumbnail
                      Center(
                        child: Container(
                          height: 120.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: PortalTheme.silverGrayBorder),
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: MemoryImage(base64Decode(base64Image)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Center(
                        child: Text(
                          'CAPTURE SECTOR: ${routePath.toUpperCase()}',
                          style: PortalTheme.statsText.copyWith(fontSize: 8.5, color: PortalTheme.infoSlate),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Comment Textfield
                      Text(
                        'OPTIONAL COMMENT',
                        style: PortalTheme.statsText.copyWith(fontSize: 8.5, color: PortalTheme.warmGrayBodyText),
                      ),
                      const SizedBox(height: 6.0),
                      TextField(
                        controller: commentController,
                        maxLines: 3,
                        style: PortalTheme.bodyText.copyWith(fontSize: 12.0, color: PortalTheme.charcoalNearBlackText),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: PortalTheme.creamBg,
                          hintText: 'Describe the issue or feedback...',
                          hintStyle: PortalTheme.smallText.copyWith(color: PortalTheme.warmGrayBodyText),
                          contentPadding: const EdgeInsets.all(12.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: PortalTheme.silverGrayBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: PortalTheme.tealNavyAccent, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Actions Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                            child: Text(
                              'CANCEL',
                              style: PortalTheme.statsText.copyWith(
                                fontSize: 10.0,
                                color: PortalTheme.charcoalNearBlackText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          SpringTapWrapper(
                            onTap: isSubmitting
                                ? null
                                : () async {
                                    setDialogState(() {
                                      isSubmitting = true;
                                    });

                                    try {
                                      await ref.read(debugReportsProvider.notifier).addReport(
                                            comment: commentController.text.trim(),
                                            screenshotBase64: base64Image,
                                            routePath: routePath,
                                          );

                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Feedback successfully transmitted to Developer Feed!'),
                                            backgroundColor: PortalTheme.successMoss,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setDialogState(() {
                                        isSubmitting = false;
                                      });
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Submission failed: $e'),
                                            backgroundColor: PortalTheme.alertTerracotta,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: PortalTheme.tealNavyAccent,
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 14.0,
                                      height: 14.0,
                                      child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                                    )
                                  : Text(
                                      'TRANSMIT',
                                      style: PortalTheme.statsText.copyWith(
                                        fontSize: 10.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine whether to show the camera button based on current route
    String routePath = '/';
    try {
      routePath = ref.watch(routerProvider).routeInformationProvider.value.uri.path;
    } catch (_) {}

    final showCamera = routePath != '/login';

    return Stack(
      children: [
        RepaintBoundary(
          key: _repaintKey,
          child: widget.child,
        ),
        if (showCamera)
          Positioned(
            bottom: 24.0,
            right: 24.0,
            child: SafeArea(
              child: SpringTapWrapper(
                onTap: _captureAndShowFeedbackDialog,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                    CurvedAnimation(parent: _cameraAnimController, curve: Curves.easeInOut),
                  ),
                  child: Container(
                    width: 56.0,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: PortalTheme.tealNavyAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: PortalTheme.tealNavyAccent.withValues(alpha: 0.3),
                          blurRadius: 12.0,
                          spreadRadius: 2.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isCapturing
                        ? const Center(
                            child: SizedBox(
                              width: 20.0,
                              height: 20.0,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.photo_camera_outlined,
                            color: Colors.white,
                            size: 26.0,
                          ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
