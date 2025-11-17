import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../../core/dependency_injection/service_locator.dart';
import '../../../leave/presentation/bloc/leave_bloc.dart';
import '../../../leave/data/models/leave_model.dart';

class AdminLeaveManagementScreen extends StatefulWidget {
  final Map<String, dynamic> adminData;

  const AdminLeaveManagementScreen({super.key, required this.adminData});

  @override
  State<AdminLeaveManagementScreen> createState() =>
      _AdminLeaveManagementScreenState();
}

class _AdminLeaveManagementScreenState extends State<AdminLeaveManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPendingLeaves();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingLeaves() async {
    final token = await ServiceLocator.authRepository.getToken();
    if (token != null) {
      context.read<LeaveBloc>().add(FetchPendingLeavesEvent(token: token));
    }
  }

  Future<void> _loadAllLeaves({String? status}) async {
    final token = await ServiceLocator.authRepository.getToken();
    if (token != null) {
      context.read<LeaveBloc>().add(
        FetchAllLeavesEvent(token: token, status: status),
      );
    }
  }

  void _showReviewDialog(LeaveModel leave, bool isApproval) {
    final commentsController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isApproval ? 'Approve Leave' : 'Reject Leave'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee: ${leave.employeeName ?? leave.empId}'),
            const SizedBox(height: 8),
            Text('Leave Type: ${leave.leaveType}'),
            const SizedBox(height: 8),
            Text('Date: ${_formatDate(leave.startDate)}'),
            const SizedBox(height: 16),
            TextField(
              controller: commentsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: isApproval ? 'Comments (Optional)' : 'Reason *',
                hintText: isApproval
                    ? 'Add any comments...'
                    : 'Provide rejection reason...',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!isApproval && commentsController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rejection reason is required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);

              final token = await ServiceLocator.authRepository.getToken();
              final adminId = widget.adminData['id'] as String;

              if (token != null) {
                if (isApproval) {
                  context.read<LeaveBloc>().add(
                    ApproveLeaveEvent(
                      token: token,
                      leaveId: leave.id,
                      adminId: adminId,
                      comments: commentsController.text.trim().isEmpty
                          ? null
                          : commentsController.text.trim(),
                    ),
                  );
                } else {
                  context.read<LeaveBloc>().add(
                    RejectLeaveEvent(
                      token: token,
                      leaveId: leave.id,
                      adminId: adminId,
                      comments: commentsController.text.trim(),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproval ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isApproval ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.hourglass_empty;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (index) {
            if (index == 0) {
              _loadPendingLeaves();
            } else {
              _loadAllLeaves(status: _filterStatus);
            }
          },
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'All Leaves'),
          ],
        ),
      ),
      body: BlocListener<LeaveBloc, LeaveState>(
        listener: (context, state) {
          if (state is LeaveActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Reload the current tab
            if (_tabController.index == 0) {
              _loadPendingLeaves();
            } else {
              _loadAllLeaves(status: _filterStatus);
            }
          } else if (state is LeaveError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            // Pending Leaves Tab
            _buildLeaveList(showActions: true),

            // All Leaves Tab with filter
            Column(
              children: [
                _buildFilterChips(),
                Expanded(child: _buildLeaveList(showActions: false)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _filterStatus == null,
            onSelected: (selected) {
              setState(() => _filterStatus = null);
              _loadAllLeaves();
            },
          ),
          FilterChip(
            label: const Text('Pending'),
            selected: _filterStatus == 'pending',
            onSelected: (selected) {
              setState(() => _filterStatus = 'pending');
              _loadAllLeaves(status: 'pending');
            },
          ),
          FilterChip(
            label: const Text('Approved'),
            selected: _filterStatus == 'approved',
            onSelected: (selected) {
              setState(() => _filterStatus = 'approved');
              _loadAllLeaves(status: 'approved');
            },
          ),
          FilterChip(
            label: const Text('Rejected'),
            selected: _filterStatus == 'rejected',
            onSelected: (selected) {
              setState(() => _filterStatus = 'rejected');
              _loadAllLeaves(status: 'rejected');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveList({required bool showActions}) {
    return BlocBuilder<LeaveBloc, LeaveState>(
      builder: (context, state) {
        if (state is LeaveLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is LeavesLoadSuccess) {
          if (state.leaves.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No leave requests found',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: showActions ? _loadPendingLeaves : _loadAllLeaves,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.leaves.length,
              itemBuilder: (context, index) {
                final leave = state.leaves[index];
                return _AdminLeaveCard(
                  leave: leave,
                  showActions: showActions,
                  formatDate: _formatDate,
                  getStatusColor: _getStatusColor,
                  getStatusIcon: _getStatusIcon,
                  onApprove: () => _showReviewDialog(leave, true),
                  onReject: () => _showReviewDialog(leave, false),
                );
              },
            ),
          );
        } else if (state is LeaveError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading leaves',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: showActions ? _loadPendingLeaves : _loadAllLeaves,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _AdminLeaveCard extends StatelessWidget {
  final LeaveModel leave;
  final bool showActions;
  final String Function(String) formatDate;
  final Color Function(String) getStatusColor;
  final IconData Function(String) getStatusIcon;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _AdminLeaveCard({
    required this.leave,
    required this.showActions,
    required this.formatDate,
    required this.getStatusColor,
    required this.getStatusIcon,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(leave.status);
    final statusIcon = getStatusIcon(leave.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with employee info and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leave.employeeName ?? leave.empId,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (leave.employeeDepartment != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          leave.employeeDepartment!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        leave.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Leave details
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    leave.leaveType,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  leave.leavePeriod,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  formatDate(leave.startDate),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Reason
            Text(
              'Reason:',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              leave.reason,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),

            // Admin comments (if any)
            if (leave.adminComments != null &&
                leave.adminComments!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Comments:',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      leave.adminComments!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action buttons for pending leaves
            if (showActions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
