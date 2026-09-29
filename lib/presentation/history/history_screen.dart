import 'package:flutter/material.dart';
import '../../core/config/supabase_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/packsense_button.dart';
import '../../data/models/analysis_history_item.dart';
import '../../data/repositories/history_repository.dart';
import '../home/widgets/recent_analysis_card.dart';
import '../recommendation_flow/step1_food_selection_screen.dart';
import 'history_detail_screen.dart';

enum HistoryViewState { loading, empty, loaded, error, unauthenticated }

/// Dedicated History screen displaying real database-backed packaging analyses.
///
/// Follows Stitch design visual hierarchy:
/// Section Header -> Analysis Cards -> Status Badges -> View Details -> Pro Tip -> Bottom Nav.
class HistoryScreen extends StatefulWidget {
  final VoidCallback? onStartAnalysis;
  final bool isTabMode;

  const HistoryScreen({
    super.key,
    this.onStartAnalysis,
    this.isTabMode = true,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryRepository _repository = HistoryRepository();
  HistoryViewState _state = HistoryViewState.loading;
  String? _errorMessage;
  List<AnalysisHistoryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    // Listen to real-time additions during the session
    _repository.historyNotifier.addListener(_onRepositoryUpdated);
  }

  @override
  void dispose() {
    _repository.historyNotifier.removeListener(_onRepositoryUpdated);
    super.dispose();
  }

  void _onRepositoryUpdated() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final updated = _repository.currentHistory;
          setState(() {
            _items = updated;
            _state = updated.isEmpty
                ? HistoryViewState.empty
                : HistoryViewState.loaded;
          });
        }
      });
    }
  }

  Future<void> _loadHistory() async {
    if (_repository.currentHistory.isNotEmpty) {
      setState(() {
        _items = _repository.currentHistory;
        _state = HistoryViewState.loaded;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _state = HistoryViewState.loading;
        _errorMessage = null;
      });
    }

    // Check if Supabase is active and if a user is authenticated
    if (SupabaseConfig.isConfigured && SupabaseConfig.isInitialized) {
      if (!SupabaseConfig.isAuthenticated) {
        // Unauthenticated state: check if we have any active session items
        final local = _repository.currentHistory;
        if (local.isNotEmpty) {
          setState(() {
            _items = local;
            _state = HistoryViewState.loaded;
          });
          return;
        } else {
          setState(() {
            _state = HistoryViewState.unauthenticated;
          });
          return;
        }
      }
    }

    try {
      final results = await _repository.fetchUserHistory(forceRefresh: true);
      if (!mounted) return;

      setState(() {
        _items = results;
        _state = results.isEmpty ? HistoryViewState.empty : HistoryViewState.loaded;
      });
    } on UnauthenticatedHistoryException {
      if (!mounted) return;
      setState(() {
        _state = HistoryViewState.unauthenticated;
      });
    } catch (e) {
      debugPrint('[HistoryScreen] Failed to load history: $e');
      if (!mounted) return;
      // If we have cached items from current session, show them with a subtle notice
      if (_repository.currentHistory.isNotEmpty) {
        setState(() {
          _items = _repository.currentHistory;
          _state = HistoryViewState.loaded;
        });
      } else {
        setState(() {
          _state = HistoryViewState.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _navigateToDetail(AnalysisHistoryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HistoryDetailScreen(item: item),
      ),
    );
  }

  void _handleStartAnalysis() {
    if (widget.onStartAnalysis != null) {
      widget.onStartAnalysis!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const Step1FoodSelectionScreen(),
        ),
      );
    }
  }

  void _showAuthSheet() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isSignUp = false;
    bool isLoading = false;
    String? authError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSignUp ? 'Create PackSense Account' : 'Sign In to PackSense',
                    style: AppTypography.titleLg.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Access and sync your real packaging analysis history across devices with secure Supabase authentication.',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (authError != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    authError!,
                    style: AppTypography.bodySm.copyWith(color: Colors.red[800]),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 18),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                PackSenseButton(
                  label: isSignUp ? 'Create Account' : 'Sign In',
                  icon: isSignUp ? Icons.person_add : Icons.login,
                  onPressed: () async {
                    if (emailController.text.trim().isEmpty ||
                        passwordController.text.trim().isEmpty) {
                      setModalState(() {
                        authError = 'Please enter both email and password.';
                      });
                      return;
                    }
                    setModalState(() {
                      isLoading = true;
                      authError = null;
                    });
                    try {
                      if (isSignUp) {
                        await SupabaseConfig.signUpWithEmailPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                      } else {
                        await SupabaseConfig.signInWithEmailPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                      }
                      if (mounted) {
                        Navigator.pop(ctx);
                        _loadHistory();
                      }
                    } catch (e) {
                      setModalState(() {
                        isLoading = false;
                        authError = e.toString();
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setModalState(() {
                        isSignUp = !isSignUp;
                        authError = null;
                      });
                    },
                    child: Text(
                      isSignUp
                          ? 'Already have an account? Sign In'
                          : "Don't have an account? Create one",
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = RefreshIndicator(
      onRefresh: _loadHistory,
      color: AppColors.secondary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            _buildSectionHeader(),
            const SizedBox(height: 14),

            // Body depending on state
            _buildStateContent(),
            const SizedBox(height: 24),

            // Pro Tip Banner
            _buildProTipBanner(),
          ],
        ),
      ),
    );

    if (widget.isTabMode) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Analysis History',
          style: AppTypography.titleLg.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: content,
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Recent Analysis',
              style: AppTypography.titleLg.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            if (_items.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_items.length}',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh, size: 20, color: AppColors.secondary),
          tooltip: 'Refresh History',
          onPressed: _loadHistory,
        ),
      ],
    );
  }

  Widget _buildStateContent() {
    switch (_state) {
      case HistoryViewState.loading:
        return _buildLoadingSkeleton();
      case HistoryViewState.unauthenticated:
        return _buildUnauthenticatedState();
      case HistoryViewState.error:
        return _buildErrorState();
      case HistoryViewState.empty:
        return _buildEmptyState();
      case HistoryViewState.loaded:
        return _buildCardsList();
    }
  }

  Widget _buildCardsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _items[index];
        return RecentAnalysisCard.fromHistory(
          historyItem: item,
          onTap: () => _navigateToDetail(item),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.structuralBorder, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 28,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No analyses yet',
            style: AppTypography.titleMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your completed packaging analyses will appear here.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          PackSenseButton(
            label: 'Start Analysis',
            icon: Icons.auto_awesome,
            variant: ButtonVariant.darkContainer,
            onPressed: _handleStartAnalysis,
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.structuralBorder, width: 1),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_person_outlined,
              size: 40, color: AppColors.secondary),
          const SizedBox(height: 12),
          Text(
            'Sign In for Cloud History',
            style: AppTypography.titleMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sign in to synchronize and preserve your real packaging analysis evaluations with Supabase authentication.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          PackSenseButton(
            label: 'Sign In / Register',
            icon: Icons.login,
            variant: ButtonVariant.darkContainer,
            onPressed: _showAuthSheet,
          ),
          const SizedBox(height: 8),
          PackSenseButton.secondary(
            label: 'Run Analysis as Guest',
            icon: Icons.auto_awesome,
            onPressed: _handleStartAnalysis,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 36, color: Colors.red[700]),
          const SizedBox(height: 12),
          Text(
            "Couldn't load your history.",
            style: AppTypography.titleMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please check your network connection and try again.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTypography.labelSm.copyWith(
                color: Colors.red[800],
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          PackSenseButton.secondary(
            label: 'Retry',
            icon: Icons.refresh,
            onPressed: _loadHistory,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.structuralBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 180,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 1,
                color: const Color(0x1FE3EAE1),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProTipBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.structuralBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.tips_and_updates,
            color: AppColors.secondary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
                children: const [
                  TextSpan(
                    text: 'Pro Tip: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Combining moisture-absorbing pads with perforated PLA reduces condensation mould by 68%.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
