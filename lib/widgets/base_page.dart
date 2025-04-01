import 'package:flutter/material.dart';
import '../utils/ui_utils.dart';

class BasePage extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const BasePage({
    Key? key,
    required this.title,
    required this.body,
    this.actions,
    this.isLoading = false,
    this.error,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return UIUtils.buildLoadingIndicator();
    }

    if (error != null) {
      return UIUtils.buildErrorWidget(error!);
    }

    return body;
  }

  static void showError(BuildContext context, String message) {
    UIUtils.showErrorDialog(
      context,
      'Error',
      message,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    UIUtils.showSnackBar(context, message);
  }

  static void showLoading(BuildContext context) {
    UIUtils.showLoadingDialog(context);
  }
} 