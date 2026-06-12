import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/api_models.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/top_app_bar.dart';

const _defaultHtml = '''
<!DOCTYPE html>
<html>
<body style="margin:0;padding:0;width:100%;height:100%">
<iframe
  src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d125426.17491930875!2d106.62965167!3d10.7544272!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x31752f4670702e31%3A0xb4c1dcc1ce5af79b!2sHo+Chi+Minh+City!5e0!3m2!1sen!2svn!4v1234567890"
  width="100%" height="100%"
  style="border:0"
  allowfullscreen=""
  loading="lazy">
</iframe>
</body>
</html>
''';

class StoreMapScreen extends StatefulWidget {
  const StoreMapScreen({super.key});

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  WebViewController? _webViewController;
  List<StoreBranchResponse> _branches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_defaultHtml);
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final branches = await ApiService().getStoreBranches();
      if (!mounted) return;
      setState(() {
        _branches = branches;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildBranchList() {
    if (_branches.isEmpty) {
      return const Center(child: Text('Chưa có thông tin cửa hàng'));
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + MediaQuery.of(context).padding.bottom),
      itemCount: _branches.length,
      itemBuilder: (context, index) => _BranchCard(
        branch: _branches[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ElectroAppBar(title: 'Cửa hàng ElectroShop'),
      body: Column(
        children: [
          SizedBox(
            height: 250,
            child: _webViewController != null
                ? WebViewWidget(controller: _webViewController!)
                : const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.destructive),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _loadBranches,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _buildBranchList(),
          ),
        ],
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final StoreBranchResponse branch;

  const _BranchCard({required this.branch});

  @override
  Widget build(BuildContext context) {
    final hasAddress = branch.address.trim().isNotEmpty;
    final mapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(branch.address)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on, color: AppColors.primary, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(branch.name, style: AppTextStyles.h3),
                if (branch.address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    branch.address,
                    style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                  ),
                ],
                if (branch.phone != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 13, color: AppColors.mutedForeground),
                      const SizedBox(width: 4),
                      Text(
                        branch.phone!,
                        style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                ],
                if (branch.workingHours != null || branch.hours.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 13, color: AppColors.mutedForeground),
                      const SizedBox(width: 4),
                      Text(
                        branch.hours,
                        style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.map_outlined, size: 14),
                        label: const Text('Xem trên bản đồ', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: hasAddress ? AppColors.primary : AppColors.mutedForeground,
                          side: BorderSide(color: hasAddress ? AppColors.primary : AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: hasAddress
                            ? () async {
                                final uri = Uri.parse(mapsUrl);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Chưa có thông tin bản đồ'),
                                    backgroundColor: AppColors.destructive,
                                  ),
                                );
                              },
                      ),
                    ),
                    if (branch.phone != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.call_outlined, size: 14),
                          label: const Text('Gọi điện', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.success,
                            side: const BorderSide(color: AppColors.success),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () => launchUrl(Uri.parse('tel:${branch.phone}')),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
