import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/sharing_token.dart';
import '../../data/repositories/sharing_token_repository.dart';
import '../../data/services/auth_service.dart';

/// Screen where user C generates a 6-character sharing token to send to friend A.
/// Token is valid for 24 hours and can only be used once.
/// If an active token already exists, it is shown instead of generating a new one.
class GenerateSharingTokenScreen extends StatefulWidget {
  const GenerateSharingTokenScreen({super.key});

  @override
  State<GenerateSharingTokenScreen> createState() =>
      _GenerateSharingTokenScreenState();
}

class _GenerateSharingTokenScreenState
    extends State<GenerateSharingTokenScreen> {
  final _repository = SharingTokenRepository();

  SharingToken? _token;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrGenerateToken();
    });
  }

  Future<void> _loadOrGenerateToken() async {
    final userId = AuthService().currentUserId;
    if (userId == null) {
      setState(() {
        _error = 'Not authenticated';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _repository.generateToken(userId);
      if (mounted) {
        setState(() {
          _token = token;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to generate token. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateNew() async {
    final userId = AuthService().currentUserId;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      // Delete the current token so generateToken creates a fresh one.
      if (_token != null) {
        await _repository.deleteToken(userId, _token!.id);
      }
      final token = await _repository.generateToken(userId);
      if (mounted) {
        setState(() {
          _token = token;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to generate token. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _copyToken() async {
    if (_token == null) return;
    await Clipboard.setData(ClipboardData(text: _token!.token));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token copied!')),
      );
    }
  }

  String _formatExpiry(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return 'Expires in ${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Share Token',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadOrGenerateToken,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final token = _token!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Your sharing token',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            token.token,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatExpiry(token.expiresAt),
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _copyToken,
            icon: const Icon(Icons.copy),
            label: const Text('Copy token'),
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Send this code to your friend who uses Friendsheet. '
              'They will enter it in your contact profile to share meetings with you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _generateNew,
            child: const Text('Generate new token'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
